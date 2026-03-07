#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:?AWS_REGION not set}"
INSTANCE_ID="${1:?Usage: ec2_ephemeral_terminate.sh <instance-id>}"

aws ec2 terminate-instances --region "$REGION" --instance-ids "$INSTANCE_ID" >/dev/null
aws ec2 wait instance-terminated --region "$REGION" --instance-ids "$INSTANCE_ID"
echo "✅ Terminated $INSTANCE_ID"