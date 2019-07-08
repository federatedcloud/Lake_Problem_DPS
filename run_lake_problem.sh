#!/usr/bin/env bash
set -ux

echo "current status: Incomplete"
#exit 1

#To Run:
#-------

export START_DIR="$(pwd)"

if [ "$(whoami)" != "nixuser" ] ; then
    echo "please run as nixuser"
    exit 1
else
    export USER="nixuser"
fi    

#TODO clean up script for clean resumption without old data contamination

# SEEDS sequence of executions
#export SEQSET={1..50}
# small for testing iteration
export SEQSET={1..5}

# DPS state limit
export DPS_LIMIT=2000
export IT_LIMIT="${DPS_LIMIT}"
#export DPS_LIMIT=2000000

# single node mpirun should auto detect all CPU cores
export MPI_ARGS=""
# multiple virtual machines will require a hostfile and more connection details
# Jetstream Openstack API domain
# export MPI_ARGS="--hostfile /home/nixuser/mpi_hostfile --mca btl self,tcp --mca btl_tcp_if_include ens3"

# Optimization (Steps 1-3):
# -------------------------

# 1. Run DPS Optimization


# formerly PBS_O_WORKDIR , best stored on NFS or similar networked file system to share executable and result files for analysis
export OPT_DIR=/home/${USER}/Lake_Problem_DPS/Optimization
export DPS_DIR="${OPT_DIR}/DPS"
export DPS_EXEC="${DPS_DIR}/LakeDPSparallel"
#mpirun --hostfile /home/nixuser/mpi_hostfile --mca btl self,tcp --mca btl_tcp_if_include ens3 /home/nixuser/Lake_Problem_DPS/Optimization/DPS/LakeDPSparallel 1 2000000
[ -d "${DPS_DIR}" ] || {
    echo "directory ${DPS_DIR} not present, exiting"
    exit 1
}
[ -f "${DPS_EXEC}" ] || {
    echo "executable ${DPS_EXEC} not present, exiting"
    exit 1
}

# Must be in that directory to run
cd $DPS_DIR

for i in $SEQSET
do
    mpirun $MPI_ARGS $DPS_EXEC $i $DPS_LIMIT
done

export DPS_OUTPUT_LINES="$(wc -l $DPS_DIR/sets/LakeDPS_*.set)"
echo $DPS_OUTPUT_LINES
echo "DPS output file had ${DPS_OUTPUT_LINES} lines"

#2. Run Interteporal Optimization
#    qsub run_IT_opt.sh


export IT_DIR="${OPT_DIR}/Intertemporal"
export IT_EXEC="${IT_DIR}/LakeITparallel"
[ -d "${IT_DIR}" ] || {
    echo "directory ${IT_DIR} not present, exiting"
    exit 1
}
[ -f "${IT_EXEC}" ] || {
    echo "executable ${IT_EXEC} not present, exiting"
    exit 1
}

# Must be in that directory to run
cd $IT_DIR

for i in $SEQSET
do
    mpirun $MPI_ARGS $IT_EXEC $i $IT_LIMIT
done
export IT_OUTPUT_FILE="$(ls $IT_DIR/sets | head -n 1)"
export IT_OUTPUT_LINES="$(wc -l $IT_OUTPUT_FILE)"
echo $IT_OUTPUT_LINES
echo "IT output file had ${IT_OUTPUT_LINES} lines"


#3. Calculate Runtime Metrics

#    sh get_objs.sh,

cd "${OPT_DIR}"
# extract columns for later processing
for SEED in $SEQSET
do
    # TODO confirm file "$DPS_DIR"/runtime/LakeDPS_S${SEED}.runtime exists
    awk 'BEGIN {FS=" "}; /^#/ {print $0}; /^[^#/]/ {printf("%s %s %s %s\n",$7,$8,$9,$10)}' "$DPS_DIR"/runtime/LakeDPS_S${SEED}.runtime >"$DPS_DIR"/objs/LakeDPS_S${SEED}.obj
    # TODO confirm file "$IT_DIR"/runtime/LakeIT_S${SEED}.runtime exists
    awk 'BEGIN {FS=" "}; /^#/ {print $0}; /^[^#/]/ {printf("%s %s %s %s\n",$101,$102,$103,$104)}' "$IT_DIR"/runtime/LakeIT_S${SEED}.runtime >"$IT_DIR"/objs/LakeIT_S${SEED}.obj
done

#    sh find_refSets.sh,

which python2 || {
    echo "Python 2 interpreter not found 'which python2' , v2.7.5 preferred, exiting"
    exit 1
}

cd "${OPT_DIR}"

python2 pareto.py "$DPS_DIR"/sets/*.set -o 6-9 -e 0.01 0.01 0.001 0.001 --output DPS.resultfile --delimiter=" " --comment="#"
cut -d ' ' -f 7-10 DPS.resultfile >DPS.reference
python2 pareto.py "$IT_DIR"/sets/*.set -o 100-103 -e 0.01 0.01 0.001 0.001 --output Intertemporal.resultfile --delimiter=" " --comment="#"
cut -d ' ' -f 101-104 Intertemporal.resultfile >Intertemporal.reference
python2 pareto.py ./*.reference -o 0-3 -e 0.01 0.01 0.001 0.001 --output Overall.reference --delimiter=" " --comment="#"

#    sh find_runtime_metrics.sh


## NAME=Runtime_Metrics_S${SEED}
## PBS="\
## #PBS -N ${NAME}\n\
## #PBS -l nodes=1\n\
## #PBS -l walltime=1:00:00\n\
## #PBS -o output/${NAME}\n\
## #PBS -e error/${NAME}\n\
## cd \$PBS_O_WORKDIR\n\
## java ${JAVA_ARGS} org.moeaframework.analysis.sensitivity.ResultFileEvaluator \
##     -d 4 -i ./DPS/objs/LakeDPS_S${SEED}.obj -r Overall.reference \
##     -o ./DPS/metrics/LakeDPS_S${SEED}.metrics\n\
## java ${JAVA_ARGS} org.moeaframework.analysis.sensitivity.ResultFileEvaluator \
##     -d 4 -i ./Intertemporal/objs/LakeIT_S${SEED}.obj -r Overall.reference \
##     -o ./Intertemporal/metrics/LakeIT_S${SEED}.metrics"
## echo -e $PBS | qsub

which java || {
    echo "Java runtime not found 'which java' , v??? preferred, exiting"
    exit 1
}

JAVA_ARGS="-cp MOEAFramework-2.4-Demo.jar"
for SEED in $SEQSET
do
#    export RM_NAME="Runtime_Metrics_S${SEED}"
    java ${JAVA_ARGS} org.moeaframework.analysis.sensitivity.ResultFileEvaluator \
        -d 4 -i ./DPS/objs/LakeDPS_S${SEED}.obj -r Overall.reference \
        -o ./DPS/metrics/LakeDPS_S${SEED}.metrics
    java ${JAVA_ARGS} org.moeaframework.analysis.sensitivity.ResultFileEvaluator \
        -d 4 -i ./Intertemporal/objs/LakeIT_S${SEED}.obj -r Overall.reference \
        -o ./Intertemporal/metrics/LakeIT_S${SEED}.metrics
done

#Re-evaluation (Steps 4-6):
#4. Generate alternate SOWs

#    sh sample_parameters.sh

# TODO OPT/../Re-evaluation

#5. Resimulate DPS and Intertemporal

#    cd DPS && qsub resimulateDPS.sh
#    cd ./../Intertemporal && qsub resimulateIT.sh

cd "$DPS_DIR"
# TODO
cd "$IT_DIR"
# TODO

#6. Calculate Robustness

#    module load python-2.7.5
#    python calcRobustness.py

#7. Figure Generation

#    python makeAllFigures.py

cd "$START_DIR"

echo "$0 all done, completed succesfully"

