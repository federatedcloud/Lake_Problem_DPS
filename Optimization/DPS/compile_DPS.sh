#!/bin/bash

cd ~nixuser/Lake_Problem_DPS/Optimization/borg

make

cd ~nixuser/Lake_Problem_DPS/Optimization/DPS

rm *.o

make
mkdir -p runtime
mkdir -p sets


