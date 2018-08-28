with import <nixpkgs> { };
# For testing local nixpkgs clone, swap with above
# with import ((builtins.getEnv "HOME") + "/workspace/nixpkgs") { }; # or:
# with import "../nixpkgs" { };
# Note that the above are not accessible during docker build

{ LakeProblemDPSDevEnv = buildEnv {
  name = "lake-problem-dps-dev-env";
  paths = [
    #
    # Always include nix, or environment will break
    # Include bash for base OSes without bash
    #
    nix
    bash
    vim
    
    #
    # MPI-related packages
    #
    binutils
    gfortran
    openmpi
    openssh
    
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
