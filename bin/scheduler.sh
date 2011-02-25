#!/bin/bash
#
# Script per l'esecuzione dei backup

##### conf
MAX_BACKUPS=2

#####
INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )
if [ ! "${2}" ]; then

	echo "Usage: $0 config1 config2 config3 ..."
else


set -m
HOSTS=$@

for i in $HOSTS; do
	
	if ! [ -f $INSTALLDIR/etc/hosts/$i.conf ]; then
       		echo "Configuration file $INSTALLDIR/etc/hosts/$i.conf not found"
        	exit 1
	fi

	echo ""
	echo '********'
	echo "Running $i"
	echo '********'
	echo ""
	
	# command
	$INSTALLDIR/bin/single-backup.sh $i &

	while [ 1 ]; do
		# jobs in corso ...
        	jobs -pl |grep Running
        	JOBS=$(jobs -pl |grep Running | wc -l )
		echo ""
        	echo "Found: $JOBS"
		echo "Max: $MAX_BACKUPS"
		echo ""
		sleep 5
		if [ "$JOBS" -lt "$MAX_BACKUPS" ]; then
			break
		fi
	done

	# incremento contatore se i job lancati sono meno di MAX_BACKUP
	#if [ "$JOBS" -le "$MAX_BACKUPS" ]; then
	#	((index=$index+1))
	#fi
done
fi
