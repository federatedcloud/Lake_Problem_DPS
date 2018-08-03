#!/bin/bash
#PBS -N run_DPS_opt
#PBS -l nodes=16:ppn=16
#PBS -l walltime=1:30:00
#PBS -j oe
#PBS -o run_DPS_opt.out

cd $PBS_O_WORKDIR
source /etc/profile.d/modules.sh
module load python-2.7.5
mpirun python run_DPS_opt.py