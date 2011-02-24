#!/bin/bash 

# ARG1: host da backuppare (e.g. esx-aiace.ciela.it)
#
# 

INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )

if [ ! "${1}" ]; then
        echo "Usage: $0 server_to_backup"
	exit
fi

RSYNC_HOST=$1
LOGFILE="$INSTALLDIR/logs/$RSYNC_HOST/rsync.log"
LOCK="$INSTALLDIR/logs/$RSYNC_HOST/lock"

mkdir -p $INSTALLDIR/logs/$RSYNC_HOST

set -e

if [ ! -d $BACKUP_DIR/$RSYNC_HOST ]; then
	echo backup dir not created
	exit 1
fi

if lockfile -! -l 43200 -r 0 "$LOCK"; then
  echo unable to start rsync, lock file exists
  exit 1
fi

trap "rm -f $LOCK > /dev/null 2>&1" exit

set +e

date2stamp () {
    date --utc --date "$1" +%s
}

dateDiff (){
    case $1 in
        -s)   sec=1;      shift;;
        -m)   sec=60;     shift;;
        -h)   sec=3600;   shift;;
        -d)   sec=86400;  shift;;
        -w)   sec=604800;  shift;;
        *)    sec=86400;;
    esac
    dte1=$(date2stamp $1)
    dte2=$(date2stamp $2)
    diffSec=$((dte2-dte1))
    if ((diffSec < 0)); then abs=-1; else abs=1; fi
    echo $((diffSec/sec*abs))
}

	# importo varibili "globali"
	. $INSTALLDIR/etc/rsbackup.conf
	# importo il file di configurazione della singola macchina
	. $INSTALLDIR/etc/hosts/$RSYNC_HOST.conf

	# load machine personanlizations
	# override delle variabili eventualmente definite
	if [ -f $BACKUP_DIR/$RSYNC_HOST/additional.conf ]; then
		. $BACKUP_DIR/$RSYNC_HOST/additional.conf
	fi


lastone=$(ls $BACKUP_DIR/$RSYNC_HOST 2>/dev/null | grep ^[0-9] | sort | tail -1 | sed -e s'/T/ /')

now=$(date +%Y-%m-%dT%H:%M:%S)

rsync $RSYNC_OPTIONS $RSYNC_ADDITIONAL_OPTIONS  \
	--exclude-from=$RSYNC_EXCLUDES \
	--files-from=$RSYNC_FILESYSTEMS -r \
	--rsync-path="$RSYNC_EXEC" --rsh="$RSYNC_SSHCMD -p $RSYNC_PORT -i $RSYNC_SSH_KEY" \
	--log-file=$LOGFILE \
	$RSYNC_USER@$RSYNC_HOST:/ $BACKUP_DIR/$RSYNC_HOST/.work  >> $LOGFILE
	
return=$?

# savelog

if [  0 = $return -o 24 = $return ]; then


	btrfs subvolume snapshot $BACKUP_DIR/$RSYNC_HOST/.work $BACKUP_DIR/$RSYNC_HOST/$now >> $LOGFILE


	if [ "${LEGATO}" ]; then 
		btrfs subvolume delete  $BACKUP_DIR/legato/$RSYNC_HOST 2>/dev/null >> $LOGFILE
		btrfs subvolume snapshot $BACKUP_DIR/$RSYNC_HOST/.work $BACKUP_DIR/legato/$RSYNC_HOST  >> $INSTALLDIR/logs/$RSYNC_HOST/rsync.log
	fi

	###delete dei vecchi

	elenco=$(ls $BACKUP_DIR/$RSYNC_HOST | grep ^[0-9])
	oldest=$(ls $BACKUP_DIR/$RSYNC_HOST | grep ^[0-9] | head -1)
	kept=0
	
	for line in $elenco
		do
		orariobackup=$line
		# nasty bug with timezones YYYY-mm-ddTHH:MM:SS is intrpreted as UTC
                # substituing T with white space interpreted as local time zone
                orariopercalcoli=$(echo -n $orariobackup | sed -e 's/T/ /')
                ore=$(dateDiff -h "$now" "$orariobackup")
                giorni=$(dateDiff -d "$now" "$orariobackup")
                giornomese=$(date --date "$orariopercalcoli" +%Y%m%d)
                settimana=$(date --date "$orariopercalcoli" +%G%V)

		if [ $ore -lt 24 ]; then
                        hourly[$ore]=$((${hourly[$ore]}+1))
                        if [ ${hourly[$ore]} -gt 1 -a $ore -ge 1 ]; then
                        btrfs subvolume delete $BACKUP_DIR/$RSYNC_HOST/$line >> $LOGFILE 2>&1
                        else
                        kept=$(($kept + 1))
                        fi
                fi
                if [ $giorni -le 30 -a $ore -ge 24 ]; then
                        daily[$giornomese]=$((${daily[$giornomese]}+1))

                         if [ ${daily[$giornomese]} -gt 1 ]; then
                        btrfs subvolume delete $BACKUP_DIR/$RSYNC_HOST/$line >> $LOGFILE 2>&1
                        else
                        kept=$(($kept + 1))
                        fi

                fi
 if [ $giorni -gt 30 ]; then
                        weekly[$settimana]=$((${weekly[$settimana]}+1))
                         if [ ${weekly[$settimana]} -gt 1 ]; then
                        btrfs subvolume delete $BACKUP_DIR/$RSYNC_HOST/$line >> $LOGFILE 2>&1
                        else
                        kept=$(($kept + 1))
                        fi

                fi
                done

		echo "Number of backups: $kept" >> $LOGFILE

		### remove the oldest if ....???
	
	 if ! [ -z $MAILTO ]; then
                mail -s "BACKUP OK - $RSYNC_HOST" $MAILTO < $LOGFILE
        fi

else

	if ! [ -z $MAILTO ]; then
		mail -s "BACKUP ERROR - $RSYNC_HOST" $MAILTO < $LOGFILE
	fi

fi 

savelog $INSTALLDIR/logs/$RSYNC_HOST/rsync.log


