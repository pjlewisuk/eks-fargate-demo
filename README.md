# EKS on Fargate Demos

## Contents

* [EKS on Fargate Demos](#eks-on-fargate-demos)
  * [Contents](#contents)
  * [Prerequisites](#prerequisites)
  * [Run the Demo/s](#run-the-demos)

## Prerequisites

1. Install [eksctl](https://eksctl.io/introduction/installation/) (`brew tap weaveworks/tap; brew install weaveworks/tap/eksctl`)
2. Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (`brew install kubectl`)
3. Install [kubectx](https://github.com/ahmetb/kubectx) (`brew install kubectx`)
4. Install [Helm](https://helm.sh/docs/intro/install/) (`brew install helm`)
5. Install curl (`brew install curl`)
6. Install jq (`brew install jq`)

## Run the Demo/s

1. Customise the cluster manifests and deploy into the region of your choice:
```bash
$ ./customise-cluster-manifests.sh
```
2. Run the **[Barebones cluster](barebones-cluster/README.md)** demo, which is good for demonstrating Fargate Profiles and how Fargate 'nodes' appear in the cluster
3. Prepare the **[EKS cluster with Fargate Profile and Managed Node Group](fargate-cluster/README.md)** demo, which prepares a cluster to run the demo below
4. **[Sock Shop](sock-shop/README.md)** - demonstrate running Weavework's Sock Shop using Managed Nodes and then AWS Fargate
