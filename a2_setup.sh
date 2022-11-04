#!/bin/sh

# Create cluster
kind create cluster --name kind-1 --config k8s/kind/cluster-config.yaml

# Create deployment
kubectl apply -f k8s/manifests/k8s/backend-deployment.yaml
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s

# Create service
kubectl apply -f k8s/manifests/k8s/backend-service.yaml

# Label ingress ready
kubectl label node kind-1-control-plane ingress-ready=true
kubectl label node kind-1-worker2 ingress-ready=true
kubectl label node kind-1-worker3 ingress-ready=true

# Create ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait -n ingress-nginx --for=condition=ready pod -l app.kubernetes.io/component=controller --timeout=1000s


sleep 3m

# Create ingress
kubectl apply -f k8s/manifests/k8s/backend-ingress.yaml