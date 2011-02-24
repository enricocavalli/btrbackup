#!/bin/bash

# ARG1: host da backuppare (e.g. esx-aiace.ciela.it)
#
# 

INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )

#### USAGE
if [ ! "${1}" ]; then
        echo "Usage: $0 server_to_backup"
	exit
fi
####

# check if machine backup directory exists
if [ -e "$BACKUP_DIR/$1" ]; then

	# importo varibili "globali"
	. $INSTALLDIR/etc/rsbackup.conf

	# load machine personanlizations
	# override delle variabili eventualmente definite
	if [ -e "$BACKUP_DIR/$1/additional.conf" ]; then
		. $BACKUP_DIR/$1/additional.conf
	fi
fi

SERV_DIR=$1
rsync $RSYNC_OPTIONS $RSYNC_ADDITIONAL_OPTIONS  \
	--exclude-from=$RSYNC_EXCLUDES \
	--files-from=$RSYNC_FILESYSTEMS -r \
	--rsync-path="$RSYNC_EXEC" --rsh="$RSYNC_SSHCMD -p $RSYNC_PORT -i $RSYNC_SSH_KEY" \
	--log-file=/rsbackup/logs/$RSYNC_SERVER.log \
	$RSYNC_USER@$RSYNC_SERVER:/ $BACKUP_DIR/$SERV_DIR
	
return=$?

if [  0 = $return -o 24 = $return ]; then


# fai due snapshot
btrfs subvolume snapshot area_scracth /snaps/macchina/$now

## il passaggio di delete preliminare è necessario
btrvs subvolume delete /legato/macchina
btrfs subvolume snapshot area_scratch /legato/macchina
delete dei vecchi
fi
