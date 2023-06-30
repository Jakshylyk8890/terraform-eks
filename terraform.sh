#!/bin/bash

# Change to the directory where your Terraform files are located
# cd ./cluster90

# Run terraform init (if necessary)
# Uncomment the following line if you need to run terraform init
# terraform init

# Run terraform plan
terraform plan -out=tfplan

# Prompt for confirmation before proceeding with apply
read -p "Do you want to apply the Terraform changes? (y/n): " answer
read -p "Enter Cluster Name: " cluster_name

if [[ "$answer" =~ ^[Yy]$ ]]; then
  # Run terraform apply using the saved plan
  terraform apply tfplan

  # Check if Terraform apply was successful
  if [ $? -eq 0 ]; then
    echo "Terraform apply completed successfully."
    
    # Update Kubernetes configuration
    aws eks update-kubeconfig --name $cluster_name

    # Check if AWS CLI command was successful
    if [ $? -eq 0 ]; then
      echo "Kubernetes configuration updated."
    else
      echo "Failed to update Kubernetes configuration."
    fi
  else
    echo "Terraform apply failed. Aborting Kubernetes configuration update."
  fi
else
  echo "Terraform apply canceled."
fi
