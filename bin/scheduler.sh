#!/bin/bash

# demone scheduler
INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )

while [ 1 ]; do

	# ora corrente
	now=$(date +%H:%M)

	# TODO: trap segnali per rilettura file di conf 
	# cerco hosts per il backup
	hosts=$(cat $INSTALLDIR/etc/scheduler.conf |  sed -e 's/#.*//'| grep -v "^\s*$" | grep $now | awk {'print $1'} | tr \\n ' ')
	#hosts=$(cat $INSTALLDIR/etc/scheduler.conf | sed -e 's/#.*//'| grep -v "^\s*$" | grep '18:00' | awk {'print $1'} | tr \\n ' ')

	lock="$INSTALLDIR/tmp/$(echo "$hosts" | md5sum | grep -o "[a-z0-9]\{32\}")"

	if [ "$hosts" == "" ]; then
		echo "No suitable host found ..."

	elif [ ! -e $lock ]; then

		echo "Initializing backups ..."
	
		# creo file per il comando da lanciare
		# evito che venga lanciato all'iterazione successiva
		touch $lock
		
		for i in $hosts; do
			# ulteriore cofigurazione del comando da laciare ...
			pool=$(cat $INSTALLDIR/etc/scheduler.conf |  sed -e 's/#.*//'| grep -v "^\s*$" | grep $now |grep $i| awk {'print $3'})
			#pool=$(cat $INSTALLDIR/etc/scheduler.conf |  sed -e 's/#.*//'| grep -v "^\s*$" | grep '18:00'|grep $i| awk {'print $3'})

			if [ "$pool" == "1" ]; then
				max_backups=4
			else
				max_backups=2
			fi
		done 
		# lancio job-runner.sh && rm $lock
		echo "Time: $now"
		echo "Max Backups: $max_backups"
		echo "Starting: $hosts"
		
		#(sleep 15 && rm $lock) &
		# TODO: cosa succede se job-runner ritorna non zero? mi resta appeso il file di lock?
		($INSTALLDIR/bin/job-runner.sh -j $max_backups $hosts && rm $lock) &
	else 
		echo "Backup still running ..."
		echo ""
	fi

	sleep 10

done
