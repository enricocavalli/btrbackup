#!/bin/bash
#
# Script per l'esecuzione dei backup

##### conf
MAX_BACKUPS=3

#####

set -m
INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )
HOSTS=$( cd $INSTALLDIR/etc/hosts/; ls | sed -r 's!.conf!!' )
hosts_array=( $HOSTS )

for i in $HOSTS; do
	
	echo ""
	echo '********'
	echo "Running $i"
	echo '********'
	echo ""
	time=$RANDOM
	((time=10+$time%30))
	#echo $time
	sleep $time &

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

