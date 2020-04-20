#!/usr/bin/env bash
set -euo pipefail

CISSUER_PROD_COUNT=$(kubectl get ClusterIssuer | grep -c letsencrypt-prod)
CISSUER_STAGE_COUNT=$(kubectl get ClusterIssuer | grep -c letsencrypt-staging)

if (( CISSUER_STAGE_COUNT > 0 ))
then
  echo "Stage Cluster Issuer already exists"
else
  echo "Stage Cluster Issuer does not exist, creating it now"
  kubectl create -f LetsEncrypt-staging.yaml
fi

if (( CISSUER_PROD_COUNT > 0 ))
then
  echo "Prod Cluster Issuer already exists"
else
  echo "Prod Cluster Issuer does not exist, creating it now"
  kubectl create -f LetsEncrypt-prod.yaml
fi
