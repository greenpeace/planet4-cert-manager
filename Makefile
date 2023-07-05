SHELL := /bin/bash

RELEASE := cert-manager
NAMESPACE := cert-manager

CHART_NAME := jetstack/cert-manager
CHART_VERSION ?= 1.9.1
#If changing chart version here, also update create_crds.sh
#Unless your upgrading to 0.15.x where you can create creds
#via helm.

DEV_CLUSTER ?= p4-development
DEV_PROJECT ?= planet-4-151612
DEV_ZONE ?= us-central1-a

PROD_CLUSTER ?= planet4-production
PROD_PROJECT ?= planet4-production
PROD_ZONE ?= us-central1-a

.DEFAULT_TARGET: status

lint: lint-yaml lint-ci

lint-yaml:
		find . -type f -name '*.yml' | xargs yamllint
		find . -type f -name '*.yaml' | xargs yamllint

lint-ci:
		circleci config validate

# Helm Initialisation
init:
	helm3 repo add jetstack https://charts.jetstack.io
	helm3 repo update

# Helm Deploy to Development
dev: lint init config-secrets
ifndef CI
	$(error Please commit and push, this is intended to be run in a CI environment)
endif
	gcloud config set project $(DEV_PROJECT)
	gcloud container clusters get-credentials $(DEV_CLUSTER) --zone $(DEV_ZONE) --project $(DEV_PROJECT)
	-kubectl create namespace $(NAMESPACE)
	./create_crds.sh
	kubectl apply -f letsencrypt-secret.yaml
	./create_issuer.sh
	helm3 upgrade --install --wait $(RELEASE) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		$(CHART_NAME)
	$(MAKE) history
	rm -f letsencrypt-secret.yaml

# Helm Deploy to Production
prod: lint init config-secrets
ifndef CI
	$(error Please commit and push, this is intended to be run in a CI environment)
endif
	gcloud config set project $(PROD_PROJECT)
	gcloud container clusters get-credentials $(PROD_PROJECT) --zone $(PROD_ZONE) --project $(PROD_PROJECT)
	-kubectl create namespace $(NAMESPACE)
	./create_crds.sh
	kubectl apply -f letsencrypt-secret.yaml
	./create_issuer.sh
	helm3 upgrade --install --wait $(RELEASE) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		$(CHART_NAME)
	$(MAKE) history
	rm -f letsencrypt-secret.yaml

# Helm status
status:
	helm3 status $(CHART_NAME) -n $(NAMESPACE)

# Display user values followed by all values
values:
	helm3 get values $(CHART_NAME) -n $(NAMESPACE)
	helm3 get values $(CHART_NAME) -n $(NAMESPACE) -a

# Display helm history
history:
	helm3 history $(RELEASE) -n $(NAMESPACE) --max=5

# List all user created certs, issuers etc.
list_data:
	kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces

# Create staging and prod issuers in cert-manager namespace
issuers:
	./create_issuer.sh

# Delete a release when you intend reinstalling it to keep history
uninstall:
	helm3 uninstall $(RELEASE) -n $(NAMESPACE) --keep-history

# Completely remove helm install, config data, persistent volumes etc.
# Before running this ensure you have deleted any other related config
destroy:
	@echo -n "Ensure you have run and deleted "make list_data" before deleting this deployment "
	@echo -n "You are about to ** DELETE DATA **, enter y if your sure ? [y/N] " && read ans && [ $${ans:-N} = y ]
	helm3 uninstall $(RELEASE) -n $(NAMESPACE)
	./delete_crds.sh

config-secrets:
	@echo -n "Appending Thanos Service Account credentials from environment to objstore.yaml"
	perl -p -i template.pl < ./letsencrypt-secret.yaml.tpl > letsencrypt-secret.yaml
