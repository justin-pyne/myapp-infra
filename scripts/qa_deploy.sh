#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:?AWS_REGION not set}"
ACCOUNT_ID="${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID not set}"
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_TAG="${IMAGE_TAG:?IMAGE_TAG not set}"

RDS_ENDPOINT="${RDS_ENDPOINT:?RDS_ENDPOINT not set}"
DB_USER="${DB_USER:?DB_USER not set}"
DB_PASSWORD="${DB_PASSWORD:?DB_PASSWORD not set}"
DB_NAME="${DB_NAME:?DB_NAME not set}"
CLIENT_ORIGIN="${CLIENT_ORIGIN:?CLIENT_ORIGIN not set}"

mkdir -p /opt/myapp

cat >/opt/myapp/docker-compose.qa.yml <<EOF
services:
  bezkoder-api:
    image: ${ECR_REGISTRY}/myapp-api:${IMAGE_TAG}
    restart: unless-stopped
    ports:
      - "6868:8080"
    environment:
      DB_HOST: ${RDS_ENDPOINT}
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: ${DB_NAME}
      DB_PORT: "3306"
      NODE_DOCKER_PORT: "8080"
      CLIENT_ORIGIN: ${CLIENT_ORIGIN}

  bezkoder-ui:
    image: ${ECR_REGISTRY}/myapp-ui:${IMAGE_TAG}
    restart: unless-stopped
    ports:
      - "8888:80"
EOF

aws ecr get-login-password --region "$REGION" | \
  docker login --username AWS --password-stdin "$ECR_REGISTRY"

docker compose -f /opt/myapp/docker-compose.qa.yml pull
docker compose -f /opt/myapp/docker-compose.qa.yml up -d