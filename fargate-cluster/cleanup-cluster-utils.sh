#!/bin/bash

# Remove external-dns
kubectl delete -f external-dns.yaml

# Remove alb-ingress-controller
kubectl delete -f alb-deployment.yaml
kubectl delete -f alb-rbac.yaml

# Remove Grafana
helm delete grafana -n kube-system

# Remove Prometheus
helm delete prometheus -n kube-system
kubectl delete -f prometheus-storageclass.yaml

# Remove Helm
# kubectl -n kube-system delete deployment metrics-server
# kubectl delete clusterrolebinding tiller
# kubectl -n kube-system delete serviceaccount tiller
# kubectl -n kube-system delete service tiller-deploy
# kubectl delete -f rbac-config.yaml

# Remove Metrics Server
DOWNLOAD_URL=$(curl -Ls "https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest" | jq -r .tarball_url)
DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< $DOWNLOAD_URL)
curl -Ls $DOWNLOAD_URL -o metrics-server-$DOWNLOAD_VERSION.tar.gz
mkdir metrics-server-$DOWNLOAD_VERSION
tar -xzf metrics-server-$DOWNLOAD_VERSION.tar.gz --directory metrics-server-$DOWNLOAD_VERSION --strip-components 1
kubectl delete -f metrics-server-$DOWNLOAD_VERSION/deploy/1.8+/
rm -rf metrics-server-*

echo ""
read -p "Would you like to delete the cluster? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    eksctl delete cluster -f fargate-mng-cluster.yaml
fi
echo "The cluster has been deleted. There may be some asynchronous tasks still running."
echo "Be sure to check the CloudFormation console to ensure the stacks have been deleted."
echo ""