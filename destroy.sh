#!/usr/bin/env bash
# Removes everything deploy.sh created.
set -euo pipefail
STACK="${STACK:-ecs-fargate-app}"
REPO="${REPO:-ecs-fargate-app}"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-eu-west-2}}"

echo "Deleting the stack $STACK"
aws cloudformation delete-stack --region "$REGION" --stack-name "$STACK"
aws cloudformation wait stack-delete-complete --region "$REGION" --stack-name "$STACK"
echo "Deleting the ECR repository $REPO"
aws ecr delete-repository --region "$REGION" --repository-name "$REPO" --force >/dev/null
echo "Done. Nothing from this project is left running."
