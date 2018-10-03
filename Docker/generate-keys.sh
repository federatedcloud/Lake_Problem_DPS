#!/bin/bash

cd Docker

if [ -d "ssh" ]; then
  chmod u+rw -R ssh
  rm -rf ssh
fi

mkdir -p ssh
cd ssh && ssh-keygen -t rsa -f id_rsa.mpi -N '' && cd ..

cat > ssh/config <<EOF
StrictHostKeyChecking no
PasswordAuthentication no
Host c1
    Hostname x.x.x.x
    Port 2222
    User nixuser
    IdentityFile /home/nixuser/.ssh/id_rsa
Host c2
    Hostname x.x.x.x
    Port 2222
    User nixuser
    IdentityFile /home/nixuser/.ssh/id_rsa
EOF

chmod 700 ssh && chmod 600 ssh/*

cd ..

