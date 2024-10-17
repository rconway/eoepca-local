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

if [ "${ACTION}" = "apply" ]; then
  kubectl -n cert-manager rollout status --watch deployment cert-manager
  kubectl -n cert-manager rollout status --watch deployment cert-manager-cainjector
  kubectl -n cert-manager rollout status --watch deployment cert-manager-webhook
  kubectl -n ingress-nginx rollout status --watch daemonset nginx-ingress-controller
fi

let status=1
while [ $status -ne 0 ]; do
  echo "Waiting to deploy Cluster Issuers..."
  kubectl ${ACTION} -f cluster-issuers.yaml 2>/dev/null
  let status=$?
  if [ $status -ne 0 ]; then sleep 5; fi
done
