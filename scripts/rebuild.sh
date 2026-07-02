#!/bin/bash

docker compose down

./scripts/build.sh

./scripts/up.sh
