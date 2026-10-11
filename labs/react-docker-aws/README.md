# React Docker AWS Deployment Lab

A React application built with Vite, Docker multi-stage builds, and Nginx.

## Tech Stack
- React and Vite
- Docker
- Nginx
- Amazon ECR and ECS
- Jenkins-oriented deployment script using AWS CLI

## Build Locally
```bash
npm install
npm run build
```

## Docker
```bash
docker build -t react-docker-aws .
docker run -d --name react-docker-aws -p 8080:80 react-docker-aws
```

Open http://localhost:8080 to test the container.

## AWS Workflow
The included deploy.bash script is designed to build and push an image to Amazon ECR, register an ECS task definition, and update an ECS service. Verify AWS resources, permissions, and configuration before running it.

## Verification
The React production build completed successfully with npm run build. Verify Docker and AWS deployment separately before describing them as completed.
