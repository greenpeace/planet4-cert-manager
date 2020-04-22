#!/usr/bin/env bash


CISSUER_STAGE_COUNT=$(kubectl get ClusterIssuer -o jsonpath='{@}' | grep -c letsencrypt-staging)
echo "Count: ${CISSUER_STAGE_COUNT}"

CISSUER_PROD_COUNT=$(kubectl get ClusterIssuer -o jsonpath='{@}' | grep -c letsencrypt-prod)

echo "Count: ${CISSUER_STAGE_COUNT}"
if (( CISSUER_STAGE_COUNT > 0 ))
then
  echo "Stage Cluster Issuer already exists"
else
  echo "Stage Cluster Issuer does not exist, creating it now"
  kubectl create -f letsencrypt-staging.yaml
fi

if (( CISSUER_PROD_COUNT > 0 ))
then
  echo "Prod Cluster Issuer already exists"
else
  echo "Prod Cluster Issuer does not exist, creating it now"
  kubectl create -f letsencrypt-prod.yaml
fi
