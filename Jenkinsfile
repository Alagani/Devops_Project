pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "docker.io"
        IMAGE_NAME = "jaga9989/devops-project"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDS = "dockerhub-creds"
        GITHUB_REPO = "https://github.com/Alagani/Devops_Project.git"
        KUBECONFIG = "${WORKSPACE}/.kube/config"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out code from ${GITHUB_REPO}"
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[url: GITHUB_REPO]]
                    ])
                }
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    echo "Building Docker image and running tests"
                    sh '''
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG}-test .
                        docker run --rm ${IMAGE_NAME}:${IMAGE_TAG}-test python3 -m pytest -v --tb=short
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh '''
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    echo "Pushing image to Docker Hub"
                    withCredentials([usernamePassword(
                        credentialsId: DOCKER_CREDS,
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                            docker push ${IMAGE_NAME}:${IMAGE_TAG}
                            docker push ${IMAGE_NAME}:latest
                            docker logout
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kind') {
            steps {
                script {
                    echo "Deploying to Kind cluster"
                    sh '''
                        # Update deployment with new image tag
                        sed -i "s|IMAGE_TAG|${IMAGE_TAG}|g" k8s/deployment.yaml
                        
                        # Apply manifests
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                        
                        # Wait for rollout
                        kubectl rollout status deployment/devops-app -n default --timeout=5m
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Verifying deployment health"
                    sh '''
                        echo "Checking pod status:"
                        kubectl get pods -n default
                        
                        echo "Checking service:"
                        kubectl get svc -n default
                        
                        echo "Pod logs:"
                        kubectl logs -l app=devops-app -n default --tail=20
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed"
            cleanWs()
        }
        success {
            echo "✓ Deployment successful: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "✗ Pipeline failed. Check logs above."
        }
    }
}
