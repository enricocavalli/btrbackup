#!/bin/sh

#set the same as in ../etc/btrbackup.conf
RSYNC_USER="rsbackup"

set -e
groupadd $RSYNC_USER
useradd  -s /bin/bash -d /home/$RSYNC_USER -m -g $RSYNC_USER $RSYNC_USER
if [ -e /etc/sudoers ]; then 
cat >>/etc/sudoers <<EOF

Cmnd_Alias RSYNC_RSBACKUP = /usr/bin/rsync
$RSYNC_USER ALL=(ALL) NOPASSWD: RSYNC_RSBACKUP

EOF
else
echo "installare sudo!"
exit 1
fi
echo "sshd: 131.175.9.105" >> /etc/hosts.allow

echo "Controlla iptables e routing (devi accettare ssh da 131.175.9.105)"

mkdir /home/$RSYNC_USER/.ssh

cat >> /home/$RSYNC_USER/.ssh/authorized_keys <<EOF
paste here your public key
EOF

chown -R $RSYNC_USER: /home/$RSYNC_USER/.ssh/
