with import <nixpkgs> { };
# For testing local nixpkgs clone, swap with above
# with import ((builtins.getEnv "HOME") + "/workspace/nixpkgs") { }; # or:
# with import "../nixpkgs" { };
# Note taht the above are not accessible during docker build

let
  MOEAFramework = stdenv.mkDerivation {
    name = "MOEAFramework";
    
    src = fetchurl {
      url = https://github.com/MOEAFramework/MOEAFramework/releases/download/v2.12/MOEAFramework-2.12-Demo.jar;
      sha256 = "0kmfdmpzpfl7f1hnfck7nyfimsd92d2fndsypfnfar6gqw5cl3w4";
    };
    phases = "installPhase";
    
    installPhase = ''
      mkdir -p $out/Lake_Problem_DPS/Optimization/
      cp -v $src $out/Lake_Problem_DPS/Optimization/
    '';
  };
in 
{ LakeProblemDPSDevEnv = buildEnv {
  name = "lake-problem-dps-dev-env";
  paths = [
    #
    # Always include nix, or environment will break
    # Include bash for base OSes without bash
    #
    nix
    bash
    
    #
    # MPI-related packages
    #
    binutils
    gfortran
    openmpi
    openssh
    
    #
    # Project code dependencies
    #
    MOEAFramework
    
    ];
  
  #shellHook = ''
  #  export LANG=en_US.UTF-8
  #'';
  };
}

#######################################
#
# Refs:
# https://stackoverflow.com/questions/46165918/how-to-get-the-name-from-a-nixpkgs-derivation-in-a-nix-expression-to-be-used-by/46173041#46173041
##
