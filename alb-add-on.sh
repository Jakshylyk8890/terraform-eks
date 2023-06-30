#!/bin/bash
# Set the variables
read -p "Enter Cluster Name: " cluster_name
account_id=$(aws sts get-caller-identity --query "Account" --output text)

# Function to display loading animation
function show_loading_animation() {
    local pid=$1
    local delay=0.2
    local spin_chars=("◢◤" "◢◤◢" "◢◤◢◤" "◢◤◢◤◢" "◢◤◢◤◢◤" "◢◤◢◤◢◤◢" "◢◤◢◤◢◤◢◤" "◢◤◢◤◢◤◢◤◢" "◢◤◢◤◢◤◢◤◢◤" "◢◤◢◤◢◤◢◤◢◤◢")

    while ps -p $pid >/dev/null 2>&1; do
        for ((i = 0; i < ${#spin_chars[@]}; i++)); do
            echo -ne "${spin_chars[i]}" "\r"
            sleep $delay
        done
    done

    echo -ne " " "\r"
}
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve

aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4

# Create IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json &
show_loading_animation $!

# Create IAM service account
eksctl create iamserviceaccount \
  --cluster=$cluster_name \
  --namespace=kube-system \
  --name=aws-load-balancer-controller90 \
  --role-name AmazonEKSLoadBalancerControllerRole90 \
  --attach-policy-arn=arn:aws:iam::$account_id:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve &
show_loading_animation $!

# Add EKS Helm repository
helm repo add eks https://aws.github.io/eks-charts & sleep 20

# Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$cluster_name \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller90 \
  & sleep 30 &
show_loading_animation $!

# Check deployment status
kubectl get deployment -n kube-system aws-load-balancer-controller

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/examples/2048/2048_full.yaml & sleep 10

kubectl get ingress/ingress-2048 -n game-2048 & sleep 10
kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller & sleep 20
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/examples/2048/2048_full.yaml & sleep 10


