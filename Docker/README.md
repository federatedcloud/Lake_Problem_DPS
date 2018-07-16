# Docker, Nix, and OpenMPI 

The container for this project is a Docker container that uses build scripts, including installing all dependencies for python and OpenMPI.  MPI nodes are set up via a call to `docker-compose` in one of the scripts.  The [Nix](https://nixos.org/nix/) package manager is also used.  This container setup was created using the OpenMPI template from [NixTemplates](https://github.com/federatedcloud/NixTemplates), with a few modification steps that are laid out below.

## Creation of Container

The following steps detail how the container was created, but you should not have to repeat this process unless you want to change the configuration.  These will assume you are starting in your home directory and will clone the NixTemplates and Lake_Problem_DPS repositories there for convenience.  If you choose a different directory, be sure to change the associated paths accordingly.

1. Clone the repository for the templates into a separate directory (not in Lake_Problem_DPS directory) and build the base alpine image
```bash
    git clone https://github.com/federatedcloud/NixTemplates
    cd NixTemplates && source Base/OpenMPI/build.sh && cd ..
```
2. Clone the repository for the Lake_Problem_DPS
```bash
    git clone https://github.com/federatedcloud/Lake_Problem_DPS
```
3. Copy the OpenMPI template and associated files to the correct place
```bash
    cd Lake_Problem_DPS && mkdir Docker
    cp -r ~/NixTemplates/Base/OpenMPI/* Docker/
    cp -r ~/NixTemplates/Utils/* Docker/
    cp ~/NixTemplates/Base/alpine_envs.sh Docker/
    cp ~/NixTemplates/docker-compose-openmpi.* Docker/
```
4. Set up ssh
```bash
    cd Docker
    mkdir ssh
    cd ssh && ssh-keygen -t rsa -f id_rsa.mpi -N '' && cd ..
    echo "StrictHostKeyChecking no" > ssh/config
    chmod 500 ssh && chmod 400 ssh/* && cd ..
```
5. Correct a few paths
```bash
    find Docker -type f -exec sed -i 's/Base\/OpenMPI/Docker/g' {} \;
    find Docker -type f -exec sed -i 's/Base/Docker/g' {} \;
    find Docker -type f -exec sed -i 's/Utils/Docker/g' {} \;
```

## Building and Testing

**Simple build**

```bash
    source Docker/build.sh
```

**Testing OpenMPI**

Start 3 MPI nodes:
```bash
    cd Docker && source docker-compose-openmpi.sh up --scale mpi_head=1 --scale mpi_node=3
```
Note this will call `Docker/build.sh`, so no need to do both.

Now from another terminal on the host system you can connect to the head node, start the `nix-shell`, and run the demo:
```bash
    docker exec -u nixuser -it docker_mpi_head_1 /bin/sh
    nix-shell . # should be from /nixenv/nixuser, or wherever default.nix was copied to
    mpirun -n 2 python /home/nixuser/mpi4py_benchmarks/all_tests.py
```

To stop the container set, just press `Ctrl-C` in the terminal where you ran
`docker-compose-openmpi.sh`.
