#!/bin/bash -e
INSTALLDIR=$( (cd -P $(dirname $0) && pwd) )
if [ ! "${1}" ]; then

echo "------"
echo "Usage:"
echo "$0 server_to_backup.cilea.it"
echo ""

else 
. $INSTALLDIR/etc/rsbackup.conf
if [ ! -d "$BACKUP_DIR/$1/.work" ]; then

	mkdir $BACKUP_DIR/$1
	btrfs subvolume create $BACKUP_DIR/$1/.work

	# do not backup with legato
	echo "+skip: *" > $BACKUP_DIR/$1/.nsr

fi

fi
