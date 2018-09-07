with import <nixpkgs> {};
# with pkgs.python36Packages;
let
  MOEAFramework = stdenv.mkDerivation {
    name = "MOEAFramework";
    
    src = fetchurl {
      url = https://github.com/MOEAFramework/MOEAFramework/releases/download/v2.12/MOEAFramework-2.12-Demo.jar;
      sha256 = "0kmfdmpzpfl7f1hnfck7nyfimsd92d2fndsypfnfar6gqw5cl3w4";
    };
    phases = "installPhase";
    
    installPhase = ''
      mkdir -p $out/
      cp $src $out/MOEAFramework-2.12-Demo.jar
    '';
  };
  Pareto = stdenv.mkDerivation {
    name = "Pareto";
    
    src = fetchurl {
      url = https://github.com/matthewjwoodruff/pareto.py/archive/1.1.1-3.tar.gz;
      sha256 = "1k057g9rgm4a9k8nfkibrqxh56kqkbs635f5xmgbzlbcchbxzp4p";
    };
    phases = "installPhase";
    
    installPhase = ''
      mkdir -p $out/
      tar -C $out/ -xzf $src
    '';
  };
#  Borg = stdenv.mkDerivation {
#    name = "Borg";
#    
#    src = fetchurl {
#      url = https://sk8foraether@bitbucket.org/dmh309/serial-borg-moea;
#  };
#  LakeProblem = stdenv.mkDerivation {
#    name = "LakeProblem"
#    
#    
#  };
in
stdenv.mkDerivation {
  name = "impurePythonEnv";
  buildInputs = [
    nix
    bash
    
    # MPI-related packages
    binutils
    gfortran
    openmpi
    openssh
    
    # python packages 
    python36Full
    python36Packages.mpi4py
    python36Packages.numpy    
    python36Packages.pip
    python36Packages.scipy
    python36Packages.virtualenv
    
    #
    # Project code dependencies
    #
    MOEAFramework
    Pareto
    boost
#    Borg
#    LakeProblem
    
  ];
  src = null;
  shellHook = ''
    export LANG=en_US.UTF-8
    cp -n ${MOEAFramework.out}/MOEAFramework-2.12-Demo.jar ~/Lake_Problem_DPS/Optimization
    cp -n ${Pareto.out}/pareto.py-1.1.1-3/pareto.py ~/Lake_Problem_DPS/Optimization
    cp -rn ${boost.out}/lib ~/
  '';
}
