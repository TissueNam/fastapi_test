#!/usr/bin/env bash
set -euo pipefail

REGION=${REGION:-ap-northeast-2}
ACCOUNT_ID=${ACCOUNT_ID:?set ACCOUNT_ID}
REPO=${REPO:?set REPO}
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO"

# ECR 로그인
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# 최신 이미지 풀 & 기동
docker pull "$ECR_URI:latest"

cd /opt/app
export ECR_URI
[ -f .env ] || cp /opt/app/.env.example .env || true

docker compose up -d
docker image prune -f
