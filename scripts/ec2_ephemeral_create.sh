#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:?AWS_REGION not set}"
AMI_ID="${AMI_ID:?AMI_ID not set}"
SUBNET_ID="${SUBNET_ID:?SUBNET_ID not set}"
SG_ID="${EPHEMERAL_SG_ID:?EPHEMERAL_SG_ID not set}"
INSTANCE_PROFILE="${INSTANCE_PROFILE:?INSTANCE_PROFILE not set}"   # e.g. LabRole instance profile name

INSTANCE_ID=$(aws ec2 run-instances \
  --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type t3.micro \
  --iam-instance-profile Name="$INSTANCE_PROFILE" \
  --subnet-id "$SUBNET_ID" \
  --security-group-ids "$SG_ID" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=myapp-ephemeral-verify}]" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "INSTANCE_ID=$INSTANCE_ID"

aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "PUBLIC_IP=$PUBLIC_IP"