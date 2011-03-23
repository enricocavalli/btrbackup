#!/bin/sh

set -e
groupadd btrbackup
useradd  -s /bin/bash -d /home/btrbackup -m -g btrbackup btrbackup
if [ -e /etc/sudoers ]; then 
cat >>/etc/sudoers <<EOF

Cmnd_Alias RSYNC_RSBACKUP = /usr/bin/rsync
btrbackup ALL=(ALL) NOPASSWD: RSYNC_RSBACKUP

EOF
else
echo "installare sudo!"
exit 1
fi
echo "sshd: 131.175.9.105" >> /etc/hosts.allow

echo "Controlla iptables e routing (devi accettare ssh da 131.175.9.105)"

mkdir /home/btrbackup/.ssh

cat >> /home/btrbackup/.ssh/authorized_keys <<EOF
paste here your public key
EOF

chown -R btrbackup: /home/btrbackup/.ssh/
