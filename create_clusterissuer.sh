#!/usr/bin/env bash
set -euo pipefail

#Create ClusterIssuer to allow cert maintenance across namespaces
# Refer to https://cert-manager.io/docs/tutorials/acme/ingress/

  kubectl apply -f letsencrypt-staging.yaml
  kubectl apply -f letsencrypt-prod.yaml
