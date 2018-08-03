# Modification of simple_mpi.py example to Project-Platypus/Platypus:
# https://github.com/Project-Platypus/Platypus/blob/master/examples/simple_mpi.py

from platypus import EpsMOEA, PoolEvaluator, Problem
from platypus.mpipool import MPIPool
from platypus.types import Real
import functools
import logging
from LakeModel_IT import LakeModel_IT

logging.basicConfig(level=logging.INFO)

if __name__ == "__main__":
    # define the problem
    problem = Problem(100,4,1)
    problem.types[:] = [Real(0.01,0.1)]*100
    epsilons = [0.01, 0.01, 0.0001, 0.0001]
    problem.constraints[:] = "==0"
    problem.function = functools.partial(LakeModel_IT, seed=1)

    # begin parallelization
    pool = MPIPool()

    # only run the algorithm on the master process
    if not pool.is_master():
        pool.wait()
        sys.exit(0)

    # instantiate the optimization algorithm to run in parallel
    with PoolEvaluator(pool) as evaluator:
        algorithm = EpsMOEA(problem, epsilons)
        algorithm.run(10000)
    
    # print the results to a file
    for solution in algorithm.result:
        print(solution.objectives)

    pool.close()