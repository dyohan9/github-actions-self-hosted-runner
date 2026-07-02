#!/bin/bash

SCALE=${1:-4}

docker compose up -d --scale runner=$SCALE