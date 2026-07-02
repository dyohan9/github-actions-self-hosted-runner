#!/bin/bash

docker build \
  --no-cache \
  --build-arg DOCKER_GID=$(getent group docker | cut -d: -f3) \
  -t github-runner .
