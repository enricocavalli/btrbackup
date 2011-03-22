#!/bin/bash -e
INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )

if [ ! "${2}" ]; then

	echo "Usage: $0 server_to_backup config_name [ mailto ]"

else

	HOST_NAME=$1
	CONFIG_NAME=$2

	. $INSTALLDIR/etc/rsbackup.conf

	if [ -e "$INSTALLDIR/bin/agent.sh" ]; then

        . $INSTALLDIR/bin/agent.sh
	
	fi

	echo "Checking client configuration, please answer yes to fingerprint request"

	ssh -i $RSYNC_SSH_KEY rsbackup@$HOST_NAME /bin/true
	return=$?

	if ! [ $return = 0 ]; then
		echo "Client not configured correclty"
		exit 1
	fi

	if [ ! -d "$BACKUP_DIR/$CONFIG_NAME/.work" ]; then

		mkdir $BACKUP_DIR/$CONFIG_NAME
		mkdir $BACKUP_DIR/$CONFIG_NAME/conf
		btrfs subvolume create $BACKUP_DIR/$CONFIG_NAME/.work

		# do not backup with legato
		echo "+skip: *" > $BACKUP_DIR/$CONFIG_NAME/.nsr

		# generating configuration file ...
		cp $INSTALLDIR/etc/filesystems.conf.default $BACKUP_DIR/$CONFIG_NAME/conf/filesystems.conf
		cp $INSTALLDIR/etc/exclude.conf.default $BACKUP_DIR/$CONFIG_NAME/conf/exclude.conf

		echo "RSYNC_HOST=$HOST_NAME" >> $INSTALLDIR/etc/hosts/$CONFIG_NAME.conf
		echo "RSYNC_FILESYSTEMS=$BACKUP_DIR/$CONFIG_NAME/conf/filesystems.conf" >> $INSTALLDIR/etc/hosts/$CONFIG_NAME.conf
		echo "RSYNC_EXCLUDES=$BACKUP_DIR/$CONFIG_NAME/conf/exclude.conf" >> $INSTALLDIR/etc/hosts/$CONFIG_NAME.conf

		if [ ${3} ]; then
			echo "MAILTO=\"$3\"" >> $INSTALLDIR/etc/hosts/$CONFIG_NAME.conf
			mail -s "Host $HOST_NAME configurato per il backup" $3 < $INSTALLDIR/etc/mail.txt
		fi

		# export via nfs for client restore
		echo >> /etc/exports
		echo "#$CONFIG_NAME" >> /etc/exports
		echo "$BACKUP_DIR/$CONFIG_NAME $HOST_NAME(ro,no_subtree_check,no_root_squash)" >> /etc/exports
		echo "$BACKUP_DIR/$CONFIG_NAME/conf $HOST_NAME(rw,no_subtree_check,no_root_squash)" >> /etc/exports
		exportfs -a

	fi


fi
