#!/bin/bash

cd Docker

if [ -d "ssh" ]; then
  chmod u+rw -R ssh
  rm -rf ssh
fi

mkdir -p ssh
cd ssh && ssh-keygen -t rsa -f id_rsa.mpi -N '' && cd ..
printf "StrictHostKeyChecking no\nPasswordAuthentication no" >> ssh/config
chmod 500 ssh && chmod 400 ssh/*

cd ..

