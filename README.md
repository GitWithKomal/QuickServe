# QuickServe — Containerization, CI/CD & Kubernetes Practice

**QuickServe** is a hands-on DevOps project that starts with a simple NGINX-served web application and explores how application code can be validated, containerized, published, deployed, and managed using modern DevOps tools.

The repository brings together GitHub Actions, Jenkins, Docker, GitHub Container Registry (GHCR), Kubernetes, Helm, and Ansible, with separate labs for practicing automation and infrastructure workflows.

## Project Overview

The goal of QuickServe is to build practical DevOps experience through implementation, testing, troubleshooting, and documentation.

The application is a lightweight static HTML page served by NGINX inside a Docker container. Around this application, the repository contains CI workflows, container image publishing pipelines, Kubernetes resources, a Helm chart, and an Ansible configuration-management lab.

## Technology Stack

| Area | Technologies |
|---|---|
| Source control | Git, GitHub |
| CI automation | GitHub Actions |
| CI/CD pipeline | Jenkins |
| Containerization | Docker, NGINX |
| Container registry | GitHub Container Registry (GHCR) |
| Container orchestration | Kubernetes |
| Kubernetes packaging | Helm |
| Configuration management | Ansible |
| Application delivery | GitHub Pages |
| Scripting and configuration | Bash, YAML |

## Architecture and Workflows

### 1. Source control and CI

Code is maintained in GitHub. The GitHub Actions CI workflow runs on pushes and pull requests, checks that the application entry file exists, and prints the configured `APP_ENV` repository variable.

### 2. Docker image publishing

A separate GitHub Actions workflow builds the Docker image and publishes it to GHCR when changes are pushed to `main`. Images are tagged with `latest` and the corresponding commit SHA.

### 3. Jenkins pipeline

The Jenkins pipeline performs the following stages:

1. Verify required source files.
2. Build the Docker image with build-number and `latest` tags.
3. Test that the image contains the expected application file and QuickServe content.
4. Authenticate to GHCR using Jenkins credentials and push the image.

The pipeline also cleans up its locally built image tags after execution.

### 4. Kubernetes and Helm

The repository includes Kubernetes Deployment and Service manifests, plus a Helm chart with configurable values and templates for resources such as Deployments, Services, Ingress, and optional autoscaling or HTTPRoute configuration.

These resources support hands-on practice with deployment configuration, replica management, resource requests and limits, chart rendering, and Kubernetes networking.

### 5. Ansible configuration management

The Ansible lab uses a control node to configure a remote Ubuntu machine. Its playbook installs NGINX, configures it to listen on port `8080` because Apache already occupies port `80`, validates the configuration, and manages the service.

The playbook was rerun successfully with no additional changes, demonstrating idempotent configuration management.

## Repository Structure

```text
QuickServe/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── docker.yml
│       └── static.yml
├── app/
│   └── index.html
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── labs/
│   └── ansible-nginx/
│       ├── README.md
│       └── nginx-setup.yml
├── quickserve-chart/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   └── templates/
├── compose.yaml
├── Dockerfile
├── Jenkinsfile
└── quickserve-ingress.yaml
```

## Run Locally with Docker

### Prerequisites

- Docker installed and running.
- Git, if cloning the repository.

### 1. Clone the repository

```bash
git clone https://github.com/GitWithKomal/QuickServe.git
cd QuickServe
```

### 2. Build the image

```bash
docker build -t quickserve:local .
```

### 3. Start the container

```bash
docker run --rm -p 8081:80 quickserve:local
```

Open `http://localhost:8081` in your browser.

The port mapping `8081:80` maps host port `8081` to container port `80`. Choose another available host port if needed.

### 4. Verify the HTTP response

In a second terminal, run:

```bash
curl -I http://localhost:8081/
```

A successful response should include:

```text
HTTP/1.1 200 OK
Server: nginx
```

The Docker build and HTTP response have been verified locally.

Press `Ctrl+C` in the container terminal to stop the test container. The `--rm` option removes that container when it stops; it does not delete the built image.

## Run with Docker Compose

The repository includes a Compose configuration for running the QuickServe container.

```bash
docker compose up -d
docker compose ps
```

The current Compose file references the `quickserve:1.0` image and maps host port `8080` to container port `80`. Build or tag the image accordingly before starting Compose, and ensure host port `8080` is available.

To stop the service:

```bash
docker compose down
```

## Kubernetes and Helm Practice

The repository contains Kubernetes manifests and a Helm chart for practicing application deployment and configuration.

Useful local commands include:

```bash
kubectl get deployments,services
kubectl get pods
helm lint ./quickserve-chart
helm template quickserve-practice ./quickserve-chart
```

These commands inspect Kubernetes resources and validate or render the Helm chart without necessarily installing or changing a release.

For actual deployment, ensure your Kubernetes context, image reference, and values are correct before applying changes.

## Ansible Lab

The [Ansible NGINX lab](./labs/ansible-nginx/README.md) documents a remote configuration-management exercise.

It covers:

- Inventory configuration and SSH connectivity.
- Installing NGINX with Ansible.
- Managing IPv4 and IPv6 listeners.
- Resolving an Apache/NGINX port conflict.
- Validating NGINX configuration and service state.
- Testing the HTTP response.
- Verifying idempotency across repeated playbook runs.

See the lab's README for the commands, implementation details, and verification results.

## Current Scope

QuickServe is a learning and portfolio project focused on practical DevOps workflows. Its workflows and labs demonstrate individual automation and deployment capabilities; they should not be interpreted as a fully integrated production platform.

The GitHub Actions CI workflow currently performs lightweight source-file verification rather than a comprehensive application test suite. The Kubernetes, Helm, and Ansible components are maintained as separate learning exercises.

Further monitoring, testing, and automation improvements can be added as they are implemented and verified.

## Author

**Komal Nimje**
Software Engineer | DevOps

- GitHub: [GitWithKomal](https://github.com/GitWithKomal)
- LinkedIn: [Komal Nimje](https://www.linkedin.com/in/komal-nimje-71593a286/)

---

This project is developed as a practical learning journey through containerization, CI/CD, orchestration, and configuration management.
