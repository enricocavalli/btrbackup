INSTALLDIR=$( (cd -P $(dirname $0) && pwd) )

 
 
. $INSTALLDIR/etc/rsbackup.conf

if [ ! -d "$BACKUP_DIR/$1/.work" ]; then

	mkdir $BACKUP_DIR/$1
	btrfs subvolume create $BACKUP_DIR/$1/.work

	# do not backup with legato
	echo "+skip: *" > $BACKUP_DIR/$1/.nsr

fi