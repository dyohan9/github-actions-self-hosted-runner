#!/bin/bash
set -e

echo "Getting organization registration token..."

REG_TOKEN=$(
curl -s \
-X POST \
-H "Authorization: Bearer ${ACCESS_TOKEN}" \
-H "Accept: application/vnd.github+json" \
https://api.github.com/orgs/${ORG}/actions/runners/registration-token \
| jq -r .token
)

cd /home/docker/actions-runner

RUNNER_NAME="$(hostname)-$(date +%s)"

./config.sh \
    --url https://github.com/${ORG} \
    --token ${REG_TOKEN} \
    --name "${RUNNER_NAME}" \
    --unattended \
    --replace

cleanup() {

    echo "Removing runner..."

    ./config.sh remove \
        --unattended \
        --token ${REG_TOKEN}

}

trap cleanup EXIT
trap cleanup SIGINT
trap cleanup SIGTERM

./run.sh