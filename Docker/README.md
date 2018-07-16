# Docker, Nix, and OpenMPI 

The container for this project is a Docker container that uses build scripts, including installing all dependencies for python and OpenMPI.  MPI nodes are set up via a call to `docker-compose` in one of the scripts.  The [Nix](https://nixos.org/nix/) package manager is also used.  This container setup was created using the OpenMPI template from [NixTemplates](https://github.com/federatedcloud/NixTemplates), with a few modification steps that are laid out below.

## Creation of Container

The following steps detail how the container was created, but you should not have to repeat this process unless you want to change the configuration.  These will assume you are starting in your home directory and will clone the NixTemplates and Lake_Problem_DPS repositories there for convenience.  If you choose a different directory, be sure to change the associated paths accordingly.

1. Clone the repository for the templates into a separate directory (not in Lake_Problem_DPS directory) and build the base alpine image
    * `git clone https://github.com/federatedcloud/NixTemplates`
    * `cd NixTemplates && source Base/OpenMPI/build.sh && cd ..`
2. Clone the repository for the Lake_Problem_DPS
    * `git clone https://github.com/federatedcloud/Lake_Problem_DPS`
3. Copy the OpenMPI template and associated files to the correct place
    * `cd Lake_Problem_DPS && mkdir Docker`
    * `cp -r ~/NixTemplates/Base/OpenMPI/* Docker/`
    * `cp -r ~/NixTemplates/Utils/* Docker/`
    * `cp ~/NixTemplates/Base/alpine_envs.sh Docker/`
    * `cp ~/NixTemplates/docker-compose-openmpi.* Docker/`
4. Set up ssh
    * `cd Docker`
    * `mkdir ssh`
    * `cd ssh && ssh-keygen -t rsa -f id_rsa.mpi -N '' && cd ..`
    * `echo "StrictHostKeyChecking no" > ssh/config`
    * `chmod 500 ssh && chmod 400 ssh/* && cd ..`
5. Correct a few paths
    * `find Docker -type f -exec sed -i 's/Base\/OpenMPI/Docker/g' {} \;`
    * `find Docker -type f -exec sed -i 's/Base/Docker/g' {} \;`
    * `find Docker -type f -exec sed -i 's/Utils/Docker/g' {} \;`


