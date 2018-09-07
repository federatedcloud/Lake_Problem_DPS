#!/bin/sh

cd /home/nixuser/Lake_Problem_DPS/Optimization/borg

make

cd /home/nixuser/Lake_Problem_DPS/Optimization/DPS

#rm *.o

make
mkdir -p runtime
mkdir -p sets


