#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

# Configuration (provide defaults that match lab-3 setup, but allow env overrides)
AWS_REGION=${AWS_REGION:-"ap-south-1"}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query "Account" --output text)}
ECR_REPO_NAME=${ECR_REPO_NAME:-"ecs-lab-repo"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
ECS_CLUSTER=${ECS_CLUSTER:-"ecs-lab-cluster"}
ECS_SERVICE=${ECS_SERVICE:-"ecs-lab-service"}
TASK_FAMILY=${TASK_FAMILY:-"lab3-task"}

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_URI="${ECR_REGISTRY}/${ECR_REPO_NAME}:${IMAGE_TAG}"

echo "============================================="
echo "Starting Jenkins Deployment to AWS ECS"
echo "Region:         $AWS_REGION"
echo "ECR Registry:   $ECR_REGISTRY"
echo "ECR Repo Name:  $ECR_REPO_NAME"
echo "Image Tag:      $IMAGE_TAG"
echo "ECS Cluster:    $ECS_CLUSTER"
echo "ECS Service:    $ECS_SERVICE"
echo "Task Family:    $TASK_FAMILY"
echo "============================================="

# Create a placeholder Dockerfile if none exists
if [ ! -f Dockerfile ]; then
  echo "No Dockerfile found. Creating a simple demo app..."
  cat <<'EOF' > Dockerfile
FROM public.ecr.aws/nginx/nginx:latest
RUN echo '<h1>Deployed successfully via Jenkins Pipeline (AWS CLI)!</h1>' > /usr/share/nginx/html/index.html
EXPOSE 80
EOF
fi

echo "=== Step 1: Authenticate Docker with AWS ECR ==="
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "=== Step 2: Build and Push Docker Image ==="
echo "Building image: $IMAGE_URI"
docker build -t "$IMAGE_URI" .

echo "Pushing image: $IMAGE_URI"
docker push "$IMAGE_URI"

echo "=== Step 3: Register New Task Definition ==="
echo "Fetching active task definition..."
# Fetch the active task definition JSON
TASK_DEF_JSON=$(aws ecs describe-task-definition --task-definition "$TASK_FAMILY" --region "$AWS_REGION")

# Clean up task definition structure for re-registration and update image URI.
# JQ strips out read-only metadata fields that AWS ECR/ECS will reject on registration.
NEW_TASK_DEF=$(echo "$TASK_DEF_JSON" | jq --arg IMAGE "$IMAGE_URI" '
  .taskDefinition |
  .containerDefinitions[0].image = $IMAGE |
  del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)
')

echo "Registering new task definition revision..."
NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
  --region "$AWS_REGION" \
  --cli-input-json "$NEW_TASK_DEF" \
  --query "taskDefinition.taskDefinitionArn" \
  --output text)

echo "Registered task definition: $NEW_TASK_DEF_ARN"

echo "=== Step 4: Update ECS Service with New Task Definition ==="
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --task-definition "$NEW_TASK_DEF_ARN" \
  --region "$AWS_REGION"

echo "=== Step 5: Wait for service deployment stability ==="
echo "Waiting for ECS service deployment to stabilize..."
aws ecs wait services-stable \
  --cluster "$ECS_CLUSTER" \
  --services "$ECS_SERVICE" \
  --region "$AWS_REGION"

echo "=== Deployment Completed Successfully ==="
