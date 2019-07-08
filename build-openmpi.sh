#!/bin/bash

source "Docker/generate-keys.sh"

source "Docker/alpine_envs.sh"

source "Docker/image_tag.sh"
REPO="nix_${BASEOS}_openmpi"
TAG=$(git_image_tag)
export NIX_OMPI_IMAGE="${REPO}:${TAG}"
echo "NIX_OMPI_IMAGE is $NIX_OMPI_IMAGE"
docker build \
       --build-arg ADDUSER="$ADDUSER" \
       --build-arg BASEOS="$BASEOS" \
       --build-arg SSH_PRIVATE_KEY="$(cat ${BITBUCKET_SSH_KEY:="$HOME/.ssh/id_rsa"})" \
       -t "$NIX_OMPI_IMAGE" -f Dockerfile-OpenMPI .

TEST_IMG="${REPO}_${TAG}_TEST"
docker create --name "$TEST_IMG" "$NIX_OMPI_IMAGE"
docker cp "$TEST_IMG:/tmp/.nix_versions" Docker/
docker cp "$TEST_IMG:/tmp/env_backup.drv" Docker/
docker rm -f "$TEST_IMG"
