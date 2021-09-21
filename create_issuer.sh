#!/usr/bin/env bash
set -euo pipefail

#Create ClusterIssuer to allow cert maintenance across namespaces
# Refer to https://cert-manager.io/docs/tutorials/acme/ingress/

  kubectl apply -f letsencrypt-staging-redirect.yaml
  kubectl apply -f letsencrypt-prod-redirect.yaml
  kubectl apply -f letsencrypt-staging-cluster.yaml
  kubectl apply -f letsencrypt-prod-cluster.yaml
  kubectl apply -f letsencrypt-staging-cluster-dns.yaml
  kubectl apply -f letsencrypt-prod-cluster-dns.yaml
  
