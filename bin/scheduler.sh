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
		echo "No suitable host found ..." > /dev/null
	else 
		lockfile -l 3600 -r 0 "$lock" 2>&1
		return=$?
		if [ "$return" == "0" ]; then

		#echo "Initializing backups ..."
	
		# creo file per il comando da lanciare
		# evito che venga lanciato all'iterazione successiva
		
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
		echo "Time: $now" >> /tmp/scheduler.log
		echo "Max Backups: $max_backups" >> /tmp/scheduler.log
		echo "Starting: $hosts" >> /tmp/scheduler.log
		echo "--------------------" >> /tmp/scheduler.log
		
		#(sleep 15 && rm $lock) &
		# TODO: cosa succede se job-runner ritorna non zero? mi resta appeso il file di lock?
		$INSTALLDIR/bin/job-runner.sh -j $max_backups $hosts  &
		else 
		echo "Backup still running ..." > /dev/null
		fi
	fi

	sleep 10

done
