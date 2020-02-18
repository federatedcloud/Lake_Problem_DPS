#!/usr/bin/env sh

echo "=== \nStarting full run of Lake_Problem_DPS code\n\n"

cd /home/nixuser/Lake_Problem_DPS/Optimization/DPS

for i in {1..50}
do
  mpirun ./LakeDPSparallel $i 2000 #00
  echo "$i DPS iteration complete"
done

cd /home/nixuser/Lake_Problem_DPS/OptimizationIntertemporal/

for i in {1..50}
do
  mpirun ./LakeITparallel $i 2000 #00
  echo "$i IT iteration complete"
done

cd /home/nixuser/Lake_Problem_DPS/Re-evaluation
./sample_parameters.sh
echo "sample params complete"
cd ./DPS && source /etc/profile.d/modules.sh && mpirun python resimulateDPS.py
echo "resimulate DPS complete"
cd ./../Intertemporal && source /etc/profile.d/modules.sh && mpirun python resimulateIT.py
echo "resimulate IT complete"
cd ./.. && python calcRobustness.py
echo "calcRobustness complete"

cd ./../FigureGeneration
python makeAllFigures.py

echo "figures complete"
