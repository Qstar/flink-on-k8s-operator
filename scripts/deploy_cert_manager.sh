#!/usr/bin/env bash

# Deploy cert-manager to the Kubernetes cluster, whic is required by mutating
# and validating webhooks of the operator. See:
# - https://book.kubebuilder.io/cronjob-tutorial/cert-manager.html
# - https://docs.cert-manager.io/en/latest/getting-started/install/kubernetes.html

set -euxo pipefail

NAMESPACE=cert-manager
CERT_MANAGER_VERSION=0.10.0

# Create a namespace to run cert-manager in
if ! kubectl get namespace "${NAMESPACE}" 1>/dev/null 2>&1; then
  kubectl create namespace "${NAMESPACE}"
fi

# Disable resource validation on the cert-manager namespace
kubectl label namespace "${NAMESPACE}" certmanager.k8s.io/disable-validation=true --overwrite

# Install the CustomResourceDefinitions and cert-manager itself
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v"${CERT_MANAGER_VERSION}"/cert-manager.yaml

sleep 10

# Verify the installation
kubectl get deployments cert-manager --namespace "${NAMESPACE}"
kubectl get deployments cert-manager-cainjector --namespace "${NAMESPACE}"
kubectl get deployments cert-manager-webhook --namespace "${NAMESPACE}"
