#!/bin/bash

# As of January 2020, EKS on Fargate is only available in the following four regions:
# US East (N. Virginia), US East (Ohio), Europe (Ireland), and Asia Pacific (Tokyo).
export AwsRegion=eu-west-1
echo AwsRegion=${AwsRegion}

read -p "Would you like to deploy the barebones cluster as well as customise the cluster manifest? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    export DeployBarebonesCluster=yes
fi

read -p "Would you like to deploy the EKS on Fargate cluster as well as customise the cluster manifest? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    export DeployFargateCluster=yes
fi

# Customising barebones cluster manifest
cd barebones-cluster
sed -i '' "s|region: .*|region: ${AwsRegion}|g" barebones-cluster.yaml

if [ "$DeployBarebonesCluster" = "yes" ]
then
  eksctl create cluster -f barebones-cluster.yaml
fi
cd ../

# Customising fargate-eks-mng cluster manifest
cd fargate-cluster
sed -i '' "s|region: .*|region: ${AwsRegion}|g" fargate-cluster.yaml

if [ "$DeployFargateCluster" = "yes" ]
then
  eksctl create cluster -f fargate-cluster.yaml
fi
cd ../

echo "Cluster creation complete."
