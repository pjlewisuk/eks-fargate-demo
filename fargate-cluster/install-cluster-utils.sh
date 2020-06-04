#!/bin/bash

# Install external-dns
kubectl apply -f external-dns.yaml

# Install alb-ingress-controller
kubectl apply -f alb-deployment.yaml
kubectl apply -f alb-rbac.yaml

# Metrics Server
DOWNLOAD_URL=$(curl -Ls "https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest" | jq -r .tarball_url)
DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< $DOWNLOAD_URL)
curl -Ls $DOWNLOAD_URL -o metrics-server-$DOWNLOAD_VERSION.tar.gz
mkdir metrics-server-$DOWNLOAD_VERSION
tar -xzf metrics-server-$DOWNLOAD_VERSION.tar.gz --directory metrics-server-$DOWNLOAD_VERSION --strip-components 1
kubectl apply -f metrics-server-$DOWNLOAD_VERSION/deploy/1.8+/
rm -rf metrics-server-*

# Configure storage class
kubectl create -f prometheus-storageclass.yaml

# Helm
# Update chart information
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# Deploy Prometheus
helm install -f prometheus-values.yaml prometheus stable/prometheus --namespace kube-system

# Deploy Grafana
helm install -f grafana-values.yaml grafana stable/grafana --namespace kube-system

# Get Grafana ELB endpoint
while true; do
    if [ $(kubectl get service --namespace kube-system grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' | wc -c) -eq 0 ]
    then
        echo "Grafana load balancer is still initialising, waiting 10 seconds before trying again..."
        sleep 10
    else
        break
    fi
done
export GrafanaELB=$(kubectl get service --namespace kube-system grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export GrafanaPassword=$(kubectl get secret --namespace kube-system grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)
echo "Grafana ELB: http://${GrafanaELB}/d/eksdemodb/kubernetes-cluster-prometheus?orgId=1"
echo "Grafana Username: admin"
echo "Grafana Password: ${GrafanaPassword}"
