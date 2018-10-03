#!/bin/sh

# for optimization
cd /home/nixuser/Lake_Problem_DPS/Optimization/borg

make

cd /home/nixuser/Lake_Problem_DPS/Optimization/DPS

make
mkdir -p runtime
mkdir -p sets

cd ~nixuser/Lake_Problem_DPS/Optimization/Intertemporal

make
mkdir -p runtime
mkdir -p sets

# for calc runtime metrics
cd /home/nixuser/Lake_Problem_DPS/Optimization/DPS

mkdir -p metrics
mkdir -p objs

cd /home/nixuser/Lake_Problem_DPS/Optimization/Intertemporal

mkdir -p metrics
mkdir -p objs

cd /home/nixuser/Lake_Problem_DPS/Optimization

mkdir -p output
mkdir -p error

# for re-evaluation
cd /home/nixuser/Lake_Problem_DPS/Re-evaluation

mkdir -p DPS/output
mkdir -p Intertemporal/output


