#!/bin/bash
# scheduler script
# legge files di configurazione dei singoli host per stabilire 
# quali backuppare e a che ora
# comand at ?

# usage 
# -l show queue
# -s start

case $@ in
	-l)
	jobs=$(atq)
	if [ "$jobs" == "" ]; then
		echo "No jobs defined ..."
	else
		echo "Job list:"
		echo $jobs
	fi
	exit
	;;
	-s)
	echo "Starting ..."
	;;
	*)
	echo "USAGE:"
	echo "$0 -l|-s"
	echo "-l list jobs"
	echo "-s start scheduler"
	exit
	;;
esac


INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )

# itero su files di configurazione
for i in $(ls $INSTALLDIR/etc/hosts); do
	. $INSTALLDIR/etc/hosts/$i	
	if [ -n "$SCHEDULE" ]; then
		echo "$i" >> $INSTALLDIR/tmp/$SCHEDULE
		unset SCHEDULE
	fi
done

for i in $( ls $INSTALLDIR/tmp ); do
	# numero di backup all'orario stimato
	num=$(cat $INSTALLDIR/tmp/$i | wc -l)	
	hosts=$(cat $INSTALLDIR/tmp/$i|sed -e 's!.conf!!' | tr \\n ' ')
	echo "$INSTALLDIR/bin/job-runner.sh $hosts" > $INSTALLDIR/tmp/at$i && at $i -v -f $INSTALLDIR/tmp/at$i
	rm $INSTALLDIR/tmp/$i && rm $INSTALLDIR/tmp/at$i
done
