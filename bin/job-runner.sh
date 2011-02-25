#!/bin/bash
#
# Script per l'esecuzione dei backup

##### conf
MAX_BACKUPS=2

#####
INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )
if [ ! "${1}" ]; then

	echo "Usage: $0 config1 config2 config3 ..."
else


HOSTS=$@

for i in $HOSTS; do
	
	if ! [ -f $INSTALLDIR/etc/hosts/$i.conf ]; then
       		echo "Configuration file $INSTALLDIR/etc/hosts/$i.conf not found"
        	exit 1
	fi
	
	# command
	$INSTALLDIR/bin/single-backup.sh $i &

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
