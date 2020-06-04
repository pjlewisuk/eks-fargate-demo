# EKS on Fargate Demo: Barebones Cluster

## Contents

* [EKS on Fargate Demo: Barebones Cluster](#eks-on-fargate-demo-barebones-cluster)
  * [Contents](#contents)
  * [Setup](#setup)
  * [Demo](#demo)
  * [Fargate Profiles](#fargate-profiles)
  * [Cleanup](#cleanup)

## Setup

1. Change into the `/barebones-cluster` directory
2. If you chose **not** to deploy the cluster earlier, deploy it now: `eksctl create cluster -f barebones-cluster.yaml`.
3. Wait for the cluster to successfully deploy.
4. Ensure you are connected to the correct cluster: `kubectx <cluster name>`
5. Remove the `coredns` deployment: `kubectl delete deployment/coredns -n kube-system`
6. Open the [EKS Console](https://console.aws.amazon.com/eks/home) and log into your AWS account

## Demo

1. Run `kubectl get pods -A` to view pods running across all namespaces. You should see something similar to this:
```bash
$ kubectl get pods -A
No resources found
```
2. Run `kubectl get nodes` to view nodes running in the cluster. You should see something similar to this:
```bash
$ kubectl get nodes
No resources found in default namespace.
```
What we've seen so far is an empty EKS cluster that's not running any pods or services. We've set this cluster up specially for this demo to illustrate a point - **this isn't how you'd ever configure a working EKS cluster**.
3. Deploy two sample Kubernetes spec files to run some pods:
```bash
kubectl apply -f ./nginx-default.yaml
kubectl apply -f ./nginx-fargate.yaml
```
4. After 30-45 seconds you should see the pods deployed into the `fargate` namespace go from `Pending` to `ContainerCreating` and then `Running` state when you run `kubectl get pods -A`. You'll find that the pods deployed into the `default` namespace never leave `Pending` status:
```bash
$ kubectl get pods -A
NAMESPACE     NAME                        READY   STATUS    RESTARTS   AGE
default       my-nginx-86459cfc9f-4rll6   0/1     Pending   0          89s
default       my-nginx-86459cfc9f-b9gr8   0/1     Pending   0          89s
fargate       my-nginx-86459cfc9f-klckm   1/1     Running   0          88s
fargate       my-nginx-86459cfc9f-t84pt   1/1     Running   0          88s
```
5. If you run `kubectl get nodes` you can see that two Fargate hosts have been registered into your EKS cluster - there should be one Fargate host for each pod that entered the `Running` state:
```bash
NAME                                                    STATUS   ROLES    AGE     VERSION
fargate-ip-192-168-120-36.eu-west-1.compute.internal    Ready    <none>   3m      v1.14.8-eks
fargate-ip-192-168-160-130.eu-west-1.compute.internal   Ready    <none>   3m      v1.14.8-eks
```
6. To see why this is the case, let's take a quick look at **Fargate Profiles**.

## Fargate Profiles

Fargate Profiles are used by EKS to decide whether to run your pods on EC2 or on Fargate. This is great because it means you don't need to make any changes to your Kubernetes spec files - the decision of whether to run your pods on EC2 or Fargate is handled within EKS when the pod is created.

1. Open the [EKS Console](https://console.aws.amazon.com/eks/) and click on your `fargate-barebones` cluster to view details about the cluster.
2. Scroll down to the **Fargate Profiles** section and click on the `default` profile that has been created automatically for you.
3. You can see that two namespaces have been configured to use Fargate: `fargate` and `kube-system`. This means that whenever pods are launched in this EKS cluster into either of those namespaces, they will run on Fargate and not EC2.
4. You can optionally create your own Fargate Profile and specify another namespace (such as `default`) and demostrate the change. Note that the decision to run on EC2 or Fargate is only taken once (at pod creation time)
5. After creating the new Fargate Profile you'll have to terminate (delete) the pod(s) running in the `default` namespace that are stuck in the `Pending` state:
```bash
kubectl delete pod my-nginx-...
```
Then run `kubectl get pods -A` and after 30-45 seconds to see your `nginx` pod starting up on Fargate, and `kubectl get nodes` to view the extra Fargate hosts that have been registered into your EKS cluster.

## Cleanup

Once your demo is finished, you can clean up your demo cluster by deleting any custom Fargate Profiles you created manually, and then simply run `eksctl delete cluster -f barebones-cluster.yaml`
