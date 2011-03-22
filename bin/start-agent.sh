#!/bin/bash

INSTALLDIR=$( (cd -P $(dirname $0) && pwd) | sed -e 's!/bin!!' )

source $INSTALLDIR/etc/rsbackup.conf


test=`/bin/ps -ef | /bin/grep ssh-agent | /bin/grep -v grep  | /usr/bin/awk '{print $2}' | xargs`

if [ "$test" = "" ]; then
   # there is no agent running
   if [ -e "$INSTALLDIR/bin/agent.sh" ]; then
      # remove the old file
      /bin/rm -f $INSTALLDIR/bin/agent.sh
   fi;
   # start a new agent
   /usr/bin/ssh-agent | /bin/grep -v echo > $INSTALLDIR/bin/agent.sh 
fi

source $INSTALLDIR/bin/agent.sh
ssh-add $RSYNC_SSH_KEY
