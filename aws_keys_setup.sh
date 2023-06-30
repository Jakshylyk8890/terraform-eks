#!/bin/bash

# Prompt the user to enter the AWS access key ID
read -p "Enter AWS Access Key ID: " access_key_id

# Prompt the user to enter the AWS secret access key
read -p "Enter AWS Secret Access Key: " secret_access_key

# Export the environment variables for the current session
export AWS_ACCESS_KEY_ID="$access_key_id"
export AWS_SECRET_ACCESS_KEY="$secret_access_key"

# Display the exported values
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"

# Add the export commands to a file
echo "export AWS_ACCESS_KEY_ID=\"$AWS_ACCESS_KEY_ID\"" > aws_keys.sh
echo "export AWS_SECRET_ACCESS_KEY=\"$AWS_SECRET_ACCESS_KEY\"" >> aws_keys.sh

# Display a success message
echo "AWS access keys have been set up successfully."
echo "To persist the environment variables, run the following command:"
echo "source aws_keys.sh"

# Create the credentials file for Velero
echo "[default]" > credentials-velero
echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> credentials-velero
echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> credentials-velero
