#!/bin/bash

# ARG1: host da backuppare (e.g. esx-aiace.ciela.it)
#
# 

INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )

#### USAGE
if [ ! "${1}" ]; then
        echo "Usage: $0 server_to_backup"
	exit
fi
####

RSYNC_HOST=$1

# check if machine backup directory exists
if [ -e "$BACKUP_DIR/$RSYNC_HOST" ]; then

	# importo varibili "globali"
	. $INSTALLDIR/etc/rsbackup.conf

	# importo il file di configurazione della singola macchina
	. $INSTALLDIR/etc/hosts/$RSYNC_HOST.conf

	# load machine personanlizations
	# override delle variabili eventualmente definite
	if [ -e "$BACKUP_DIR/$RSYNC_HOST/additional.conf" ]; then
		. $BACKUP_DIR/$RSYNC_HOST/additional.conf
	fi
fi

mkdir -p $INSTALLDIR/logs/$RSYNC_HOST

rsync $RSYNC_OPTIONS $RSYNC_ADDITIONAL_OPTIONS  \
	--exclude-from=$RSYNC_EXCLUDES \
	--files-from=$RSYNC_FILESYSTEMS -r \
	--rsync-path="$RSYNC_EXEC" --rsh="$RSYNC_SSHCMD -p $RSYNC_PORT -i $RSYNC_SSH_KEY" \
	--log-file=$INSTALLDIR/logs/$RSYNC_HOST/rsync.log \
	$RSYNC_USER@$RSYNC_HOST:/ $BACKUP_DIR/$RSYNC_HOST/.work
	
return=$?

# savelog

if [  0 = $return -o 24 = $return ]; then

	now=$(date +%Y-%m-%dT%H:%M:%S)

	btrfs subvolume snapshot $BACKUP_DIR/$RSYNC_HOST/.work $BACKUP_DIR/$RSYNC_HOST/$now >> $INSTALLDIR/logs/$RSYNC_HOST/rsync.log


	if [ "${LEGATO}" ]; then 
		btrfs subvolume delete  $BACKUP_DIR/legato/$RSYNC_HOST 2>/dev/null
		btrfs subvolume snapshot $BACKUP_DIR/$RSYNC_HOST/.work $BACKUP_DIR/legato/$RSYNC_HOST
	fi

	###delete dei vecchi
fi

savelog $INSTALLDIR/logs/$RSYNC_HOST/rsync.log
