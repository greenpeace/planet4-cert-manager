# SHELL := /bin/bash

RELEASE := cert-manager
NAMESPACE := cert-manager

CHART_NAME := jetstack/cert-manager
CHART_VERSION ?= 0.14.1

DEV_CLUSTER ?= p4-development
DEV_PROJECT ?= planet-4-151612
DEV_ZONE ?= us-central1-a

PROD_CLUSTER ?= planet4-production
PROD_PROJECT ?= planet4-production
PROD_ZONE ?= us-central1-a

.DEFAULT_TARGET: status

lint:
	@find . -type f -name '*.yml' | xargs yamllint
	@find . -type f -name '*.yaml' | xargs yamllint

init:
	helm init --client-only
	helm repo add jetstack https://charts.jetstack.io
	helm repo update

dev: lint init
ifndef CI
	$(error Please commit and push, this is intended to be run in a CI environment)
endif
	gcloud config set project $(DEV_PROJECT)
	gcloud container clusters get-credentials $(DEV_CLUSTER) --zone $(DEV_ZONE) --project $(DEV_PROJECT)

#Install the CustomResourceDefinition resources first separately
	./create_crds.sh

	-kubectl label namespace $(NAMESPACE) certmanager.k8s.io/disable-validation=true
	helm upgrade --install --force --wait $(RELEASE) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		$(CHART_NAME)
	$(MAKE) history

#Check if exists or create ClusterIssuers
	./create_clusterissuer.sh

prod: lint init
ifndef CI
	$(error Please commit and push, this is intended to be run in a CI environment)
endif
	gcloud config set project $(PROD_PROJECT)
	gcloud container clusters get-credentials $(PROD_PROJECT) --zone $(PROD_ZONE) --project $(PROD_PROJECT)

#Install the CustomResourceDefinition resources first separately
		./create_crds.sh

	-kubectl label namespace $(NAMESPACE) certmanager.k8s.io/disable-validation=true
	helm upgrade --install --force --wait $(RELEASE) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		$(CHART_NAME)
	$(MAKE) history

#Check if exists or create ClusterIssuers
	./create_clusterissuer.sh

destroy:
	helm delete --purge $(RELEASE)

history:
	helm history $(RELEASE) --max=5
