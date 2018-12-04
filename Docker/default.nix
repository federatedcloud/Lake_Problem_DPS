with import <nixpkgs> {};
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
    
    # python 2.7 packages 
    python27Full
    python27Packages.mpi4py
    python27Packages.numpy    
    python27Packages.pip
    python27Packages.scipy
    python27Packages.virtualenv
    
    #
    # Project code dependencies
    #
    jdk
    MOEAFramework
    Pareto
    boost
    
  ];
  src = null;
  shellHook = ''
    export LANG=en_US.UTF-8
    cp -n ${MOEAFramework.out}/MOEAFramework-2.12-Demo.jar ~/Lake_Problem_DPS/Optimization
    cp -n ${Pareto.out}/pareto.py-1.1.1-3/pareto.py ~/Lake_Problem_DPS/Optimization
    cp -rn ${boost.out}/lib ~/
  '';
}
