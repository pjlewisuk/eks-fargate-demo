# EKS on Fargate Demo: Fargate and Managed Nodes Demo Cluster

## Contents

* [EKS on Fargate Demo: Fargate and Managed Nodes Demo Cluster](#eks-on-fargate-demo-fargate-and-managed-nodes-demo-cluster)
  * [Contents](#contents)
  * [Setup](#setup)
  * [Run Demo](#run-demo)
  * [Cleanup](#cleanup)

## Setup

Run these steps at least one hour before you plan to start your demo.

1. Change into the `/fargate-cluster` directory
2. If you chose **not** to deploy the cluster earlier, deploy it now: `eksctl create cluster -f fargate-cluster.yaml`.
3. Wait for the cluster to successfully deploy.
4. Ensure you are connected to the correct cluster: `kubectx <cluster name>`
5. Run the `customise-app-manifests.sh` script from the repository top level to customise the application manifests, based on the cluster that you just created.
6. Create the `fargate` namespace within your cluster: `kubectl apply -f fargate-namespace.yaml`
7. Run the `install-cluster-utils.sh` script to install various utilities including [Helm](https://helm.sh/), [Metrics Server](https://github.com/kubernetes-sigs/metrics-server), and [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/).
8. Open your browser, open the URL and log in with the credentials supplied at the end of the script
9. Open the following pages from the AWS Console and log into your AWS account:
   * [EKS Console](https://console.aws.amazon.com/eks/home)
   * [IAM Console](https://console.aws.amazon.com/iam/home)
   * [Route 53 Console](https://console.aws.amazon.com/route53/home)
     * Clear down any existing Route 53 records if you wish
   * [Load Balancer Console](https://console.aws.amazon.com/ec2/v2/home?#LoadBalancers:sort=loadBalancerName)

## Run Demo

If you wish, you can run these steps as part of the demo, or complete them beforehand to keep the demo shorter.

1. Run `kubectl get pods -A` to check the status of the `alb-ingress-controller-*` and `external-dns` pods until they are both in the `Running` state
2. Continue with the Sock Shop demo [README.md](../sock-shop/README.md#)

## Cleanup

1. If you have deployed any services that have created ELBs, ALBs or NLBs, ensure you delete these from the cluster using `kubectl`
2. If you have deployed any Helm releases, ensure you delete these from the cluster using `helm ls -a --all-namespaces | awk 'NR > 1 { print  "-n "$2, $1}' | xargs -L1 helm delete`
3. Change into the `/fargate-cluster` directory
4. Run `eksctl delete cluster -f fargate-cluster.yaml` to delete the cluster
