#!/usr/bin/env bash
set -euo pipefail

#Install the CustomResourceDefinition resources first separately.
#https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm
#Kubernetes 1.15+
  kubectl replace --validate=false \
	 -f https://github.com/cert-manager/cert-manager/releases/download/v1.6.3/cert-manager.crds.yaml
