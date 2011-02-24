#!/bin/bash -e
INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )

if [ ! "${1}" ]; then

	echo "Usage: $0 server_to_backup"

else 
	. $INSTALLDIR/etc/rsbackup.conf
	if [ ! -d "$BACKUP_DIR/$1/.work" ]; then

		mkdir $BACKUP_DIR/$1
		#btrfs subvolume create $BACKUP_DIR/$1/.work

		# do not backup with legato
		echo "+skip: *" > $BACKUP_DIR/$1/.nsr

		# generating configuration file ...
		cp $INSTALLDIR/etc/filesystems.conf.default $BACKUP_DIR/$1/filesystems
		echo "RSYNC_FILESYSTEMS=$INSTALLDIR/filesystems" >> $BACKUP_DIR/$1/filesystems
		cp $INSTALLDIR/etc/exclude.conf.default $BACKUP_DIR/$1/exclude 
		echo "RSYNC_EXCLUDES=$INSTALLDIR/exclude" >> $BACKUP_DIR/$1/exclude
		echo "RSYNC_HOST=$1" > $INSTALLDIR/etc/hosts/$1.conf
		#cp $INSTALLDIR/etc/additional.conf $BACKUP_DIR/$1/
	fi

fi
