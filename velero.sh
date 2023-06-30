#!/bin/bash
read -p "Enter s3 Bucket name: " bucket_name
# Check if the bucket already exists
bucket_exists=$(aws s3 ls "s3://$bucket_name" 2>&1)

if [[ $bucket_exists == *"NoSuchBucket"* ]]; then
  # Create S3 Bucket
  aws s3 mb s3://$bucket_name
  echo "S3 bucket '$bucket_name' created."
else
  echo "S3 bucket '$bucket_name' already exists."
fi
# Install Velero
velero install \
    --provider aws \
    --bucket $bucket_name \
    --secret-file ./credentials-velero \
    --backup-location-config region=us-east-1 \
    --use-restic \
    --use-volume-snapshots=false \
    --plugins velero/velero-plugin-for-aws:v1.5.0

kubectl logs deployment/velero -n velero & sleep 10
kubectl get pod -n velero & sleep 10
kubectl get bsl -n velero
