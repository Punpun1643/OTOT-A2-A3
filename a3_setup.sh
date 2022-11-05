#!/bin/sh

# Create metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 
kubectl -nkube-system edit deploy/metrics-server

# Add flag --kubelet-insecure-tls to deployment.spec.containers[].args[]
kubectl -nkube-system rollout restart deploy/metrics-server

# Apply hpa
kubectl apply -f k8s/manifests/k8s/backend-hpa.yaml

# Create zone aware deployment
kubectl apply -f k8s/manifests/k8s/backend-deployment-zone-aware.yaml

sleep 3m

# Initial
echo before stress
kubectl describe hpa

max=4000
for i in `seq 1 $max`
do
    curl --silent -o /dev/null localhost
done

echo after stress
kubectl describe hpa

sleep 3m

# apply another version
kubectl apply -f k8s/manifests/k8s/backend-deployment-zone-aware.yaml

sleep 3m

echo get zones
kubectl get nodes -L topology.kubernetes.io/zone

echo topology spread
kubectl get po -lapp=backend-zone-aware -owide --sort-by='.spec.nodeName'