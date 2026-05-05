pipeline {
    agent any

    environment {
        // Docker Configuration
        DOCKER_REGISTRY = "docker.io"
        IMAGE_NAME = "jaga9989/devops-project"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = "dockerhub-creds"
        
        // Git Configuration
        GIT_REPO = "https://github.com/Alagani/Devops_Project.git"
        GIT_BRANCH = "main"
        
        // Kubernetes Configuration
        KUBECONFIG = "/var/jenkins_home/.kube/config"
        K8S_NAMESPACE = "default"
        APP_NAME = "devops-app"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        disableConcurrentBuilds()
    }

    triggers {
        githubPush()
    }

    stages {
        stage('1. Checkout') {
            steps {
                script {
                    echo "=== Stage 1: Checking out source code ==="
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${GIT_BRANCH}"]],
                        userRemoteConfigs: [[url: GIT_REPO]]
                    ])
                    echo "✓ Code checkout completed"
                }
            }
        }

        stage('2. Unit Tests') {
            steps {
                script {
                    echo "=== Stage 2: Running unit tests ==="
                    sh '''
                        echo "Building test image..."
                        docker build -t ${IMAGE_NAME}:test-${IMAGE_TAG} .
                        
                        echo "Running pytest..."
                        docker run --rm ${IMAGE_NAME}:test-${IMAGE_TAG} python3 -m pytest -v --tb=short
                        
                        echo "Cleaning up test image..."
                        docker rmi ${IMAGE_NAME}:test-${IMAGE_TAG}
                    '''
                    echo "✓ All tests passed"
                }
            }
        }

        stage('3. Build Docker Image') {
            steps {
                script {
                    echo "=== Stage 3: Building production Docker image ==="
                    sh '''
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    '''
                    echo "✓ Docker image built: ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('4. Push to Registry') {
            steps {
                script {
                    echo "=== Stage 4: Pushing image to Docker Hub ==="
                    withCredentials([usernamePassword(
                        credentialsId: DOCKER_CREDENTIALS_ID,
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
                    echo "✓ Image pushed to registry"
                }
            }
        }

        stage('5. Deploy to Kubernetes') {
            steps {
                script {
                    echo "=== Stage 5: Deploying to Kubernetes ==="
                    sh '''
                        export KUBECONFIG=${KUBECONFIG}
                        
                        # Update deployment manifest with new image tag
                        sed "s|IMAGE_TAG|${IMAGE_TAG}|g" k8s/deployment.yaml > k8s/deployment-${BUILD_NUMBER}.yaml
                        
                        # Apply Kubernetes manifests
                        kubectl apply -f k8s/deployment-${BUILD_NUMBER}.yaml --validate=false
                        kubectl apply -f k8s/service.yaml --validate=false
                        kubectl apply -f k8s/ingress.yaml --validate=false
                        
                        # Wait for deployment to complete
                        kubectl rollout status deployment/${APP_NAME} -n ${K8S_NAMESPACE} --timeout=5m
                        
                        # Cleanup temp file
                        rm k8s/deployment-${BUILD_NUMBER}.yaml
                    '''
                    echo "✓ Deployment successful"
                }
            }
        }

        stage('6. Verify Deployment') {
            steps {
                script {
                    echo "=== Stage 6: Verifying deployment ==="
                    sh '''
                        export KUBECONFIG=${KUBECONFIG}
                        
                        echo "\n=== Deployment Status ==="
                        kubectl get deployment ${APP_NAME} -n ${K8S_NAMESPACE}
                        
                        echo "\n=== Pod Status ==="
                        kubectl get pods -l app=${APP_NAME} -n ${K8S_NAMESPACE}
                        
                        echo "\n=== Service Status ==="
                        kubectl get svc ${APP_NAME} -n ${K8S_NAMESPACE}
                        
                        echo "\n=== Ingress Status ==="
                        kubectl get ingress ${APP_NAME}-ingress -n ${K8S_NAMESPACE}
                        
                        echo "\n=== Recent Pod Logs ==="
                        kubectl logs -l app=${APP_NAME} -n ${K8S_NAMESPACE} --tail=10 --ignore-errors=true || echo "Logs not available yet"
                    '''
                    echo "✓ Verification completed"
                }
            }
        }
    }

    post {
        always {
            echo "\n=== Pipeline Execution Summary ==="
            echo "Build Number: ${BUILD_NUMBER}"
            echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            cleanWs()
        }
        success {
            echo "\n✓✓✓ PIPELINE SUCCESSFUL ✓✓✓"
            echo "Application deployed successfully!"
            echo "Access URL: http://devops-app.local"
        }
        failure {
            echo "\n✗✗✗ PIPELINE FAILED ✗✗✗"
            echo "Check logs above for error details"
        }
        unstable {
            echo "\n⚠ PIPELINE UNSTABLE ⚠"
        }
    }
}
