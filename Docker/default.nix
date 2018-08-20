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
      cp -v $src $out/MOEAFramework-2.12-Demo.jar
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
    
  ];
  #postBuild = ''
  #  echo "AAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHHHHH" > /opt/diditwork.txt
  #  cp ${MOEAFramework.out}/MOEAFramework-2.12-Demo.jar /opt
  #'';
  src = null;
  shellHook = ''
    export LANG=en_US.UTF-8
    cp ${MOEAFramework.out}/MOEAFramework-2.12-Demo.jar ~/
  '';
}
