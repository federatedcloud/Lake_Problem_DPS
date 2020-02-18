#!/usr/bin/env python
import os.path
import sys
import subprocess as sp

def main():
    print("=== \nStarting full run of Lake_Problem_DPS code\n\n")

    try_cmd("cd /home/nixuser/Lake_Problem_DPS")

    check_depends()

    ### Step 1 - Optimization ###
    run_DPS(5, 2000) #TESTING
    #run_DPS(50, 2000000) #PODUCTION

    run_IT(5, 2000) #TESTING
    #run_IT(50, 2000000) #PRODUCTION
    
    run_re_eval()
    
    run_fig_gen()
    
    sys.exit("\n Run Complete \n===")

def run_fig_gen():
    try_cmd("cd ./../FigureGeneration")
    try_cmd("python makeAllFigures.py")

def run_re_eval():
    try_cmd("cd Re-evaluation")
    try_cmd("sh ./sample_parameters.sh")
    try_cmd("cd ./DPS && source /etc/profile.d/modules.sh && mpirun python resimulateDPS.py")
    try_cmd("cd ./../Intertemporal && source /etc/profile.d/modules.sh && mpirun python resimulateIT.py")
    try_cmd("cd ./.. && python calcRobustness.py")

def run_DPS(seqset, DPS_limit, mpi_args=""):
    # Runs the Direct Policy Search portion of Optimization
    print("Running DPS...")
    
    for x in range(0,seqset):
        try_cmd("mpirun ./Optimization/DPS/LakeDPSparallel %s %s"%(x,DPS_limit))
    
    print("DPS complete")

def run_IT(seqset, IT_limit, mpi_args=""):
    # Runs the Intertemporal portion of Optimization
    print("Running IT...")
    
    for x in range(0,seqset):
        try_cmd("mpirun ./Optimization/IT/LakeITparallel %s %s"(x,IT_limit))
    
    print("IT complete")

def check_depends():
    # Checks the dependencies for the run and shows an error if not met
    user = "nixuser"
    who = try_cmd_out("whoami")
    who = who.rstrip()
    if (who != user):
        sys.exit("ERROR: must run as nixuser, quitting.\n")

    # python2
    py_version = try_cmd_out(["python2", "--version"])
    if "2.7" not in py_version:
        sys.exit("ERROR: no Python 2 found (prefer 2.7.5), quitting.\n")

    # java
    java_which = try_cmd_out(["which", "java"])
    if "java" not in java_which:
        sys.exit("ERROR: no java found, quitting.\n")

    # MOEAFramework
    if not os.path.isfile("./Optimization/MOEAFramework-2.12-Demo.jar"):
        sys.exit("ERROR: no MOEAFramework file (expecting 2.12), quitting.\n")

def try_cmd(cmd, stdout=None, stderr=None):
    # Run the command in the string cmd using sp.check_call()
    # If there is a problem running, a CalledProcessError will occur
    # and the program will quit.
    print("$%s\n" %cmd)

    try:
        retval = sp.check_call(cmd, shell=True, stdout=stdout, stderr=stderr)
    except sp.CalledProcessError:
        sys.exit("%s \n The above command did not work, quitting.\n" %cmd)

def try_cmd_out(cmd):
    # Run the command in the string cmd using sp.check_output()
    # If there is a problem running, a CalledProcessError will occur and the
    # program will quit.  If not, output of the command is stored in retval.
    print("$%s" %cmd)

    try:
        retval = sp.check_output(cmd, stderr=sp.STDOUT)
    except sp.CalledProcessError:
        sys.exit("%s \n The above command did not work, quitting.\n" %cmd)

    print(retval)
    return retval

####################
##     MAIN       ##
####################

if __name__ == "__main__":
    main()


