#!/usr/bin/env bash
# Builds the container image, pushes it to ECR and deploys the stack.
# Needs Docker and the AWS CLI. Works in AWS CloudShell.
set -euo pipefail
cd "$(dirname "$0")"

STACK="${STACK:-ecs-fargate-app}"
REPO="${REPO:-ecs-fargate-app}"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-eu-west-2}}"
ACCOUNT="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"
TAG="$(date +%Y%m%d-%H%M%S)"
IMAGE="$REGISTRY/$REPO:$TAG"

echo "1/4  Making sure the ECR repository exists"
aws ecr describe-repositories --repository-names "$REPO" --region "$REGION" >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name "$REPO" --region "$REGION" \
       --image-scanning-configuration scanOnPush=true >/dev/null

echo "2/4  Building the image"
docker build --platform linux/amd64 -t "$IMAGE" .

echo "3/4  Pushing $IMAGE"
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REGISTRY"
docker push "$IMAGE"

echo "4/4  Deploying the stack (first run takes about 5 minutes)"
aws cloudformation deploy --region "$REGION" --stack-name "$STACK" \
  --template-file template.yaml --capabilities CAPABILITY_IAM \
  --parameter-overrides ImageUri="$IMAGE"

URL="$(aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
  --query "Stacks[0].Outputs[?OutputKey=='Url'].OutputValue" --output text)"
echo
echo "Live at $URL"
echo "This stack costs money while it runs. Remove it with: bash destroy.sh"
