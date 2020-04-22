#!/usr/bin/env bash


CISSUER_STAGE_COUNT=$(kubectl get ClusterIssuer -o jsonpath='{@}' | grep -c letsencrypt-staging)
CISSUER_PROD_COUNT=$(kubectl get ClusterIssuer -o jsonpath='{@}' | grep -c letsencrypt-prod)

echo "Count Stagine Cluster Issuers: ${CISSUER_STAGE_COUNT}"
if (( CISSUER_STAGE_COUNT > 0 ))
then
  echo "Stage Cluster Issuer already exists"
else
  echo "Stage Cluster Issuer does not exist, creating it now"
  kubectl create -f letsencrypt-staging.yaml
fi

echo "Count Prod Cluster Issuers: ${CISSUER_PROD_COUNT}"
if (( CISSUER_PROD_COUNT > 0 ))
then
  echo "Prod Cluster Issuer already exists"
else
  echo "Prod Cluster Issuer does not exist, creating it now"
  kubectl create -f letsencrypt-prod.yaml
fi
