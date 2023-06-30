#!/bin/bash

# Set the variables
read -p "Enter Cluster Name: " cluster_name
account_id=$(aws sts get-caller-identity --query "Account" --output text)
# cluster_name="test-altair" 
# account_id="548284560599"

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

# Get the OIDC ID
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5) &
show_loading_animation $!

# Associate IAM OIDC provider
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve &
show_loading_animation $!

# List OpenID Connect providers and filter by OIDC ID
provider_name=$(aws iam list-open-id-connect-providers | findstr $oidc_id | cut -d "/" -f 4) &
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4
show_loading_animation $!

# Create IAM service account
eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster $cluster_name \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve &
show_loading_animation $!

# Create EBS add-on
eksctl create addon --name aws-ebs-csi-driver --cluster $cluster_name --service-account-role-arn arn:aws:iam::$account_id:role/AmazonEKS_EBS_CSI_DriverRole --force &
show_loading_animation $!

# Get EBS add-on status
eksctl get addon --name aws-ebs-csi-driver --cluster $cluster_name
current_date=$(date +%d-%m-%Y)
echo "Successfully installed EBS CSI add-on on $current_date" 


read -p "Do you want to Deploy a sample application for testing EBS-CSI? (y/n): " ebs
echo "If you have manifest files locally just skip this"
read -p "Do you want to clone in Git Hub? (y/n): " git_hub

# Check if aws-ebs-csi-driver directory exists
if [[ "$git_hub" =~ ^[Yy]$ ]]; then
  # Clone the aws-ebs-csi-driver repository
  git clone https://github.com/kubernetes-sigs/aws-ebs-csi-driver.git & sleep 80
fi

if [[ "$ebs" =~ ^[Yy]$ ]]; then
  # ... previous code ...

  # Change to the EBS CSI driver example directory
  cd aws-ebs-csi-driver/examples/kubernetes/dynamic-provisioning/

  # Apply the manifests
  kubectl apply -f manifests/

  # Describe the EBS storage class
  kubectl describe storageclass ebs-sc

  # Get the pods
  kubectl get pods --watch &
  sleep 30

  # Get the persistent volumes
  kubectl get pv &
  sleep 10
  kubectl delete -f manifests/
fi
#eksctl delete addon --cluster $cluster_name --name aws-ebs-csi-driver --preserve
