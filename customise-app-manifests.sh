#!/bin/bash

export AwsRegion=eu-west-1
export ClusterName=eks-fargate-demo # Unless you changed this in fargate-cluster.yaml before creating the cluster
export DomainName=eks.pjlewis.cloud # The top level domain or sub-domain that you wish you use for name ALB endpoints
export VpcId=$(aws ec2 describe-vpcs --filters Name=tag:alpha.eksctl.io/cluster-name,Values=$ClusterName --query 'Vpcs[*].VpcId' --output text)
aws configure set default.region ${AwsRegion}
echo AwsRegion=${AwsRegion}
echo ClusterName=${ClusterName}
echo DomainName=${DomainName}
echo VpcId=${VpcId}
echo "Default AWS region is $(aws configure get default.region)"

read -p "Are the above values correct? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Nn]$ ]]
then
    exit
fi

# Customising grafana manifest
echo "Customising grafana manifest"
cd fargate-cluster
sed -i '' "s|defaultRegion: .*|defaultRegion: ${AwsRegion}|g" grafana-values.yaml

# Customising alb-ingress-controller and external-dns manifest
echo "Customising alb-ingress-controller and external-dns manifest"
export AlbIngressControllerIamRoleArn=$(aws cloudformation describe-stacks --stack-name eksctl-${ClusterName}-addon-iamserviceaccount-kube-system-alb-ingress-controller --query 'Stacks[0].Outputs[?OutputKey==`Role1`].OutputValue')
export ExternalDnsIamRoleArn=$(aws cloudformation describe-stacks --stack-name eksctl-${ClusterName}-addon-iamserviceaccount-kube-system-external-dns --query 'Stacks[0].Outputs[?OutputKey==`Role1`].OutputValue')
echo AlbIngressControllerIamRoleArn=${AlbIngressControllerIamRoleArn}
echo ExternalDnsIamRoleArn=${ExternalDnsIamRoleArn}
sed -i '' "s|eks.amazonaws.com/role-arn: .*|eks.amazonaws.com/role-arn: ${AlbIngressControllerIamRoleArn}|g" alb-rbac.yaml
sed -i '' "s|--cluster-name=.*|--cluster-name=${ClusterName}|g" alb-deployment.yaml
sed -i '' "s|--aws-region=.*|--aws-region=${AwsRegion}|g" alb-deployment.yaml
sed -i '' "s|--aws-vpc-id=.*|--aws-vpc-id=${VpcId}|g" alb-deployment.yaml
sed -i '' "s|eks.amazonaws.com/role-arn: .*|eks.amazonaws.com/role-arn: ${ExternalDnsIamRoleArn}|g" external-dns.yaml
sed -i '' "s|- --domain-filter=.*|- --domain-filter=${DomainName}|g" external-dns.yaml
cd ../

# Customising sock-shop manifests
echo "Customising sock-shop manifests"
cd sock-shop
sed -i '' "s|- host: sock-shop..*|- host: sock-shop.${DomainName}|g" sock-shop-complete-demo*.yaml
cd ../

echo "Finished customising application manifests"
echo "Demo is ready to run"
