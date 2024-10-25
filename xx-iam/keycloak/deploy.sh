#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

ACTION="${1:-apply}"

kubectl kustomize \
  --enable-helm \
  --helm-kube-version $(kubectl version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion') \
  | kubectl ${ACTION} -f -
