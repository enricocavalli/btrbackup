#!/bin/bash

INSTALLDIR=$( (cd -P $(dirname $0) && pwd) )

# check if machine backup directory exists
# load machine personanlizations
 
. $INSTALLDIR/etc/rsbackup.conf

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
