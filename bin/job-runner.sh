#!/bin/bash
#
# Script per l'esecuzione dei backup

while getopts "j:" OPZIONE

do 
	case $OPZIONE in
		j ) parallel_jobs=$OPTARG;;
	esac
done

shift $(($OPTIND - 1))

MAX_BACKUPS=${parallel_jobs:-"2"}

INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )
if [ ! "${1}" ]; then

	echo "Usage: $0 [ -j <max_jobs> ] config1 config2 config3 ..."
else


HOSTS=$@

for i in $HOSTS; do
	
	if ! [ -f $INSTALLDIR/etc/hosts/$i.conf ]; then
       		echo "Configuration file $INSTALLDIR/etc/hosts/$i.conf not found"
        	exit 1
	fi
	
	# command
	$INSTALLDIR/bin/single-backup.sh $i 2>&1 >> $INSTALLDIR/logs/job-runner.log &

	while [ 1 ]; do
		# jobs in corso ...
        	JOBS=$(jobs -r | wc -l )
		sleep 5
		if [ "$JOBS" -lt "$MAX_BACKUPS" ]; then
			break
		fi
	done

done
echo "Jobs esauriti"
fi

savelog $INSTALLDIR/logs/job-runner.log > /dev/null
