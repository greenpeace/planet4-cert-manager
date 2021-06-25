#!/usr/bin/env bash
set -euo pipefail

#Install the CustomResourceDefinition resources first separately.
#https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm
#Kubernetes 1.15+
  kubectl delete \
	 -f https://github.com/jetstack/cert-manager/releases/download/v1.4.0/cert-manager.crds.yaml
