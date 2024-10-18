#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

ACTION="${1:-apply}"

if [ "${ACTION}" = "apply" ]; then
  helm upgrade --install apisix apisix \
    --repo https://charts.apiseven.com \
    --version 2.9.0 \
    --namespace iam \
    --create-namespace \
    -f values.yaml
else
  helm -n iam uninstall apisix
fi
