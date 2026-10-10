pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        IMAGE_NAME = 'ghcr.io/gitwithkomal/quickserve'
    }

    stages {
        stage('Verify Source') {
            steps {
                sh '''
                    set -eu
                    test -f Dockerfile
                    test -f app/index.html
                    echo "Required application files found."
                    cat app/index.html
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu
                    docker build \
                      -t "${IMAGE_NAME}:${BUILD_NUMBER}" \
                      -t "${IMAGE_NAME}:latest" .
                '''
            }
        }

        stage('Test Docker Image') {
            steps {
                sh '''
                    set -eu
                    docker run --rm \
                      --entrypoint /bin/sh \
                      "${IMAGE_NAME}:${BUILD_NUMBER}" \
                      -c 'test -f /usr/share/nginx/html/index.html &&
                          grep -q "QuickServe" /usr/share/nginx/html/index.html'

                    echo "Docker image test passed."
                '''
            }
        }

        stage('Push to GHCR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'ghcr-credentials',
                        usernameVariable: 'GHCR_USER',
                        passwordVariable: 'GHCR_TOKEN'
                    )
                ]) {
                    sh '''
                        set +x
                        set -eu

                        export DOCKER_CONFIG="$(mktemp -d)"
                        trap 'docker logout ghcr.io >/dev/null 2>&1 || true; rm -rf "$DOCKER_CONFIG"' EXIT

                        printf '%s' "$GHCR_TOKEN" |
                          docker login ghcr.io \
                            --username "$GHCR_USER" \
                            --password-stdin

                        docker push "${IMAGE_NAME}:${BUILD_NUMBER}"
                        docker push "${IMAGE_NAME}:latest"
                    '''
                }
            }
        }
    }

    post {
        always {
            sh '''
                docker image rm \
                  "${IMAGE_NAME}:${BUILD_NUMBER}" \
                  "${IMAGE_NAME}:latest" \
                  >/dev/null 2>&1 || true
            '''
        }
    }
}