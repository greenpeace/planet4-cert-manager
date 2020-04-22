#!/usr/bin/env bash
set -euo pipefail

CISSUER_STAGE=$(kubectl get ClusterIssuer | grep letsencrypt-stage > stage.txt 2>/dev/null)
CISSUER_PROD=$(kubectl get ClusterIssuer | grep letsencrypt-prod > prod.txt 2>/dev/null)

echo "$CISSUER_STAGE"
if [ -s stage.txt ]
 then
 echo "Stage Cluster Issuer already exists"
 rm stage.txt
else
 echo "Stage Cluster Issuer does not exist, creating it now"
#  kubectl create -f letsencrypt-staging.yaml
fi

echo "$CISSUER_PROD"
if [ -s prod.txt ]
then
  echo "Prod Cluster Issuer already exists"
  rm prod.txt
else
  echo "Prod Cluster Issuer does not exist, creating it now"
#  kubectl create -f letsencrypt-prod.yaml
fi
