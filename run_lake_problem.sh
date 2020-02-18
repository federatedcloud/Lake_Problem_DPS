#!/usr/bin/env sh

echo "=== \nStarting full run of Lake_Problem_DPS code\n\n"

cd /home/nixuser/Lake_Problem_DPS/Optimization/DPS

for i in {1..50}
do
  mpirun ./LakeDPSparallel $i 2000 #00
done

cd /home/nixuser/Lake_Problem_DPS/Optimization/Intertemporal/

for i in {1..50}
do
  mpirun ./LakeITparallel $i 2000 #00
done

cd /home/nixuser/Lake_Problem_DPS/Re-evaluation
./sample_parameters.sh
cd ./DPS && source /etc/profile.d/modules.sh && mpirun python resimulateDPS.py
cd ./../Intertemporal && source /etc/profile.d/modules.sh && mpirun python resimulate.py
cd ./.. && python calcRobustness.py

cd ./../FigureGeneration
python makeAllFigures.py


