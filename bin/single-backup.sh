
rsync $RSYNC_OPTIONS $RSYNC_ADDITIONAL_OPTIONS  \
	--exclude-from=$RSYNC_EXCLUDES \
	--files-from=$FILESYSTEM_DA_BACKUPPARE -r \
	--rsync-path="$RSYNC_EXEC" --rsh="$RSYNC_SSHCMD -p $RSYNC_PORT -i $RSYNC_SSH_KEY" \
	--log-file=/rsbackup/logs/$RSYNC_SERVER.log \
	$RSYNC_USER@$RSYNC_SERVER:/ $BACKUP_DIR/$SERV_DIR
