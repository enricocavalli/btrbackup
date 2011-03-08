#!/bin/sh

set -e
groupadd rsbackup
useradd  -s /bin/bash -d /home/rsbackup -m -g rsbackup rsbackup
if [ -e /etc/sudoers ]; then 
cat >>/etc/sudoers <<EOF

Cmnd_Alias RSYNC_RSBACKUP = /usr/bin/rsync
rsbackup ALL=(ALL) NOPASSWD: RSYNC_RSBACKUP

EOF
else
echo "installare sudo!"
exit 1
fi
echo "sshd: 131.175.9.105" >> /etc/hosts.allow

echo "Controlla iptables e routing (devi accettare ssh da 131.175.9.105)"

mkdir /home/rsbackup/.ssh

cat >> /home/rsbackup/.ssh/authorized_keys <<EOF
ssh-dss AAAAB3NzaC1kc3MAAACBAMJ80GrRP6kIfJTpv0NZwFvFvqWwXYMyFu2VsHVPgGUkbNZnjhUugeIdESlBof+mYqogVicHZnX4ogCkTTlrvrmV0lzfJ0QNWicj/FDa4hP68ZaRj1dv+iy2sMUpIiKuVzYkGJVj0VZjwBQS5BVHbc7/JDuMgQHsX21x6FWm/FipAAAAFQD6+U48YN5JUo96KWAaKaZOS94qmwAAAIEAiaF6Yoj7RRVk56LHU85mfOZ5wDAlenn9qAugpvDYonJUrMYXMYG7ijw1DvsGhlIslO5YWOt2EBikoSs8+YQSEZ+v7aHB8s151kBsmerCSFv22xcpPsWnirTPynnVtd+ZCBo1Jl0Ee4iEyt6NGxrCHX2fxcY71p2746MVB3jzZLMAAACAF8kXYpBnkJK2fXKL7bym+e3h40/m29VoOpPoJzA6X8lJTbluHiqqCkE7PbNylmhS9x3/ozKAYNvfnCEhIoLP9fj/U6+fs4PwI6QbaS2m4fO3AIATCOari7CGiYpScMVrAHjcEXMFe/6SB2goNc/vpedXRAp/9WwokfrnyskSvTg= rsbackup-key
EOF

chown -R rsbackup: /home/rsbackup/.ssh/
