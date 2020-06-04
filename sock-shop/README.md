# EKS on Fargate Demo: Weaveworks Sock Shop

## Contents

* [EKS on Fargate Demo: Weaveworks Sock Shop](#eks-on-fargate-demo-weaveworks-sock-shop)
  * [Contents](#contents)
  * [Setup](#setup)
  * [Run Demo](#run-demo)
  * [Cleanup](#cleanup)

## Setup

1. Follow the steps in [Fargate and Managed Nodes Demo Cluster](../fargate-cluster/README.md) to set up your cluster

## Run Demo

1. Change into the `/sock-shop` directory from the repository root folder
2. Open your [Route 53 Console](https://console.aws.amazon.com/route53/home), switch into the relevant Hosted Zone, and show that you don't have any `sock-shop` DNS records in the zone.
3. Deploy Sock Shop onto EC2 worker nodes: `kubectl apply -f sock-shop-complete-demo.yaml`
4. Open the [Load Balancer](https://console.aws.amazon.com/ec2/v2/home?#LoadBalancers:sort=loadBalancerName) page on the EC2 Console and you should see a new ALB in the `provisioning` state
5. Switch back to the [Route 53 Console](https://console.aws.amazon.com/route53/home) and show that two `sock-shop` NS records have appeared: an `ALIAS` record pointing to the ALB that's being provisioned, and a `TXT` record with information about who created the record
6. Navigate to the Sock Shop vanity URL, and show the app working. Add some socks to your basket, go to the checkout, log in as user/password, and complete the order
7. Switch back to the terminal, and show the pods and nodes running in the `sock-shop` namespace:
```bash
kubectl get pods,nodes -n sock-shop
```
8. You can see that there aren't any more nodes after deploying the sock shop compared to before, so all the pods running the microservices are running on the EC2 worker nodes
9. Switch to the [EKS console](https://console.aws.amazon.com/eks/home), navigate to your cluster, and add a new Fargate Profile with the following properties:
    * Name: `sock-shop`
    * Pod execution role: Use the `FargatePodExecutionRole` for this cluster
    * Subnets: Private subnets only (remove any Public subnets)
    * Namespace: `sock-shop`
    * Label:
      * Key = `scheduler`
      * Value = `fargate`
10. Wait for the Fargate Profile to become active, then switch back to the terminal
11. Deploy the Fargate version of sockshop:
```bash
kubectl apply -f sock-shop-complete-demo-fargate.yaml
```
12. View the pods in the `sock-shop` namespace, and highlight that most of them are now being re-deployed because we applied a new K8s label to them so they match the selectors in our Fargate Profile, which will allow the mutating admission webhook to update the pod spec and schedule the pods to run on Fargate
13. Wait for all the pods to go into `Running` state
14. Switch back to the Sock Shop website and show it working again
15. Switch back to the terminal and view the pods and nodes in the `sock-shop` namespace:
```bash
kubectl get pods,nodes -n sock-shop
```
16. You should point out that we now have a much larger number of `fargate-ip` nodes registered into the cluster, as most of the pods running the sock shop are now running on Fargate
17. Deploy the 'scale-out' version of sock-shop, which will scale some of the microservices to 3 replicas, hence adding more Fargate nodes:
```bash
kubectl apply -f sock-shop-complete-demo-fargate-scaleout.yaml`
```
18. Wait for the new pods to start running, and then view pods and nodes in the `sock-shop` namespace to demonstrate that a number of new `fargate-ip` nodes have joined the cluster

## Cleanup

1. Remove the `sock-shop` app deployment by running `kubectl delete -f sock-shop-complete-demo.yaml`
2. Follow the remaining cleanup steps in the demo cluster [README.md](../fargate-mng-eks-cluster/README.md#cleanup)
