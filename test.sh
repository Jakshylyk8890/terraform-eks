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

# Create IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json &
pid1=$!
show_loading_animation $pid1

# Create IAM service account
eksctl create iamserviceaccount \
    --cluster=$cluster_name \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --attach-policy-arn=arn:aws:iam::$account_id:policy/AWSLoadBalancerControllerIAMPolicy \
    --approve &
pid2=$!
show_loading_animation $pid2

# Add EKS Helm repository
helm repo add eks https://aws.github.io/eks-charts
sleep 20

# Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$cluster_name \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    & pid3=$!
sleep 30
show_loading_animation $pid3

# Check deployment status
kubectl get deployment -n kube-system aws-load-balancer-controller
