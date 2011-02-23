#!/bin/bash -e
INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )

if [ ! "${1}" ]; then

	echo "Usage: $0 server_to_backup.cilea.it"

else 
	. $INSTALLDIR/etc/rsbackup.conf
	if [ ! -d "$BACKUP_DIR/$1/.work" ]; then

		mkdir $BACKUP_DIR/$1
		btrfs subvolume create $BACKUP_DIR/$1/.work

		# do not backup with legato
		echo "+skip: *" > $BACKUP_DIR/$1/.nsr

	fi

fi
