# DevOps CI/CD Pipeline Project - Complete Documentation

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technologies Used](#technologies-used)
4. [Prerequisites](#prerequisites)
5. [Project Setup](#project-setup)
6. [Pipeline Stages](#pipeline-stages)
7. [Kubernetes Deployment](#kubernetes-deployment)
8. [Monitoring Setup](#monitoring-setup)
9. [Troubleshooting Guide](#troubleshooting-guide)
10. [Commands Reference](#commands-reference)
11. [Key Learnings](#key-learnings)
12. [Future Enhancements](#future-enhancements)

---

## 🎯 Project Overview

**Project Name:** DevOps CI/CD Pipeline with FastAPI

**Description:** A complete end-to-end DevOps pipeline that automates the build, test, and deployment of a FastAPI application to a local Kubernetes cluster using Jenkins, Docker, and monitoring tools.

**Repository:** https://github.com/Alagani/Devops_Project.git

**Key Features:**
- ✅ Automated CI/CD pipeline with Jenkins
- ✅ FastAPI application with unit tests
- ✅ Docker containerization with multi-stage builds
- ✅ Kubernetes deployment on kind (local cluster)
- ✅ Nginx Ingress for routing
- ✅ Prometheus & Grafana monitoring
- ✅ Auto-trigger on Git push

---

## 🏗️ Architecture

```
┌─────────────┐
│   GitHub    │
│  Repository │
└──────┬──────┘
       │ (Git Push)
       ▼
┌─────────────┐
│   Jenkins   │
│   Pipeline  │
└──────┬──────┘
       │
       ├─► 1. Checkout Code
       ├─► 2. Run Unit Tests
       ├─► 3. Build Docker Image
       ├─► 4. Push to DockerHub
       ├─► 5. Deploy to Kubernetes
       └─► 6. Verify Deployment
              │
              ▼
       ┌──────────────┐
       │ Kind Cluster │
       │  (K8s Local) │
       └──────┬───────┘
              │
              ├─► FastAPI App (2 replicas)
              ├─► Nginx Ingress
              ├─► Prometheus
              └─► Grafana
```

---

## 🛠️ Technologies Used

| Technology | Version | Purpose |
|------------|---------|---------|
| FastAPI | Latest | Python web framework |
| Uvicorn | Latest | ASGI server |
| Docker | Latest | Containerization |
| Jenkins | LTS | CI/CD automation |
| Kubernetes (kind) | v1.35.0 | Container orchestration |
| Nginx Ingress | Latest | Ingress controller |
| Prometheus | Latest | Metrics collection |
| Grafana | Latest | Monitoring dashboards |
| Python | 3.9 | Programming language |
| Pytest | Latest | Testing framework |

---

## 📦 Prerequisites

### Software Requirements
- Windows 10/11
- Docker Desktop
- Git
- Python 3.9+
- kubectl
- kind (Kubernetes in Docker)

### Accounts Needed
- GitHub account
- DockerHub account

---

## 🚀 Project Setup

### Step 1: Project Structure

```
devops-project/
├── app/
│   ├── app.py              # FastAPI application
│   ├── test_app.py         # Unit tests
│   └── requirements.txt    # Python dependencies
├── k8s/
│   ├── deployment.yaml     # Kubernetes deployment
│   ├── service.yaml        # Kubernetes service
│   ├── ingress.yaml        # Nginx ingress
│   ├── prometheus.yaml     # Prometheus setup
│   └── grafana.yaml        # Grafana setup
├── Dockerfile              # Multi-stage Docker build
├── Jenkinsfile            # CI/CD pipeline definition
├── kind-config.yaml       # Kind cluster configuration
└── README.md
```

### Step 2: Initialize Git Repository

```bash
cd C:\Users\a.jagadeesh\Downloads\devops-project
git init
git add .
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/Alagani/Devops_Project.git
git push -u origin main
```

### Step 3: Create FastAPI Application

**File: `app/app.py`**
```python
from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.get("/")
def home():
    return {"message": "Hello DevOps Project 🚀", "version": "1.0.0"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5000)
```

**File: `app/test_app.py`**
```python
from fastapi.testclient import TestClient
from app import app

client = TestClient(app)

def test_home():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello DevOps Project 🚀", "version": "1.0.0"}
```

**File: `app/requirements.txt`**
```
fastapi
uvicorn
pytest
httpx
```

### Step 4: Create Dockerfile

**File: `Dockerfile`**
```dockerfile
FROM python:3.9-slim AS builder
WORKDIR /app
COPY app/ .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY app/ .
EXPOSE 5000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5000"]
```

### Step 5: Create Kubernetes Manifests

**File: `k8s/deployment.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-app
  labels:
    app: devops-app
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: devops-app
  template:
    metadata:
      labels:
        app: devops-app
    spec:
      containers:
      - name: devops-app
        image: jaga9989/devops-project:IMAGE_TAG
        imagePullPolicy: Always
        ports:
        - containerPort: 5000
          name: http
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 10
```

**File: `k8s/service.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: devops-app
  labels:
    app: devops-app
spec:
  type: ClusterIP
  selector:
    app: devops-app
  ports:
    - port: 80
      targetPort: 5000
      protocol: TCP
      name: http
```

**File: `k8s/ingress.yaml`**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: devops-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: devops-app.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: devops-app
            port:
              number: 80
```

### Step 6: Setup Kind Cluster

**File: `kind-config.yaml`**
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
```

**Create Cluster:**
```bash
kind create cluster --config kind-config.yaml
```

**Install Nginx Ingress:**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s
```

### Step 7: Setup Jenkins in Docker

**Run Jenkins Container:**
```bash
docker run -d -p 8080:8080 -p 50000:50000 --name jenkins --restart=on-failure -v jenkins_home:/var/jenkins_home -v //var/run/docker.sock:/var/run/docker.sock --group-add 0 jenkins/jenkins:lts
```

**Install Docker CLI in Jenkins:**
```bash
docker exec -u root jenkins sh -c "apt-get update && apt-get install -y docker.io"
docker exec -u root jenkins usermod -aG docker jenkins
docker restart jenkins
```

**Install kubectl in Jenkins:**
```bash
docker exec -u root jenkins sh -c "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/"
```

**Setup Kubeconfig:**
```bash
docker exec -u root jenkins mkdir -p /var/jenkins_home/.kube
docker cp %USERPROFILE%\.kube\config jenkins:/var/jenkins_home/.kube/config
docker exec -u root jenkins chown jenkins:jenkins /var/jenkins_home/.kube/config
docker exec jenkins kubectl config set-cluster kind-kind --server=https://kind-control-plane:6443 --insecure-skip-tls-verify=true
docker network connect kind jenkins
```

**Access Jenkins:**
- URL: http://localhost:8080
- Get initial password: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

---

## 🔄 Pipeline Stages

### Jenkinsfile Overview

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = "docker.io"
        IMAGE_NAME = "jaga9989/devops-project"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = "dockerhub-creds"
        GIT_REPO = "https://github.com/Alagani/Devops_Project.git"
        GIT_BRANCH = "main"
        KUBECONFIG = "/var/jenkins_home/.kube/config"
        K8S_NAMESPACE = "default"
        APP_NAME = "devops-app"
    }
    
    stages {
        // 6 stages defined
    }
}
```

### Stage 1: Checkout
- Clones source code from GitHub
- Checks out the main branch

### Stage 2: Unit Tests
- Builds test Docker image
- Runs pytest inside container
- Cleans up test image

### Stage 3: Build Docker Image
- Builds production Docker image
- Tags with build number and 'latest'

### Stage 4: Push to Registry
- Authenticates with DockerHub
- Pushes both tagged and latest images
- Logs out securely

### Stage 5: Deploy to Kubernetes
- Updates deployment manifest with new image tag
- Applies deployment, service, and ingress
- Waits for rollout to complete

### Stage 6: Verify Deployment
- Checks deployment status
- Lists running pods
- Shows service and ingress info
- Displays recent logs

---

## ☸️ Kubernetes Deployment

### Deployment Strategy
- **Type:** RollingUpdate
- **Replicas:** 2
- **Max Surge:** 1
- **Max Unavailable:** 0
- **Zero Downtime:** Yes

### Resource Limits
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "500m"
```

### Health Checks
- **Readiness Probe:** HTTP GET on port 5000, checks every 5s
- **Liveness Probe:** HTTP GET on port 5000, checks every 10s

### Access Methods

**Method 1: Port Forward (Recommended for Local)**
```bash
kubectl port-forward svc/devops-app 5000:80 -n default
```
Access: http://localhost:5000

**Method 2: Ingress (with hosts file)**
Add to `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1 devops-app.local
```
Access: http://devops-app.local

---

## 📊 Monitoring Setup

### Prometheus

**Deploy:**
```bash
kubectl apply -f k8s/prometheus.yaml
```

**Access:**
```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
```
URL: http://localhost:9090

**Features:**
- Metrics collection every 15s
- Kubernetes pod discovery
- Query interface
- Alerting capabilities

### Grafana

**Deploy:**
```bash
kubectl apply -f k8s/grafana.yaml
```

**Access:**
```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
```
URL: http://localhost:3000
- Username: `admin`
- Password: `admin`

**Setup Data Source:**
1. Login to Grafana
2. Configuration → Data Sources → Add data source
3. Select Prometheus
4. URL: `http://prometheus.monitoring.svc.cluster.local:9090`
5. Save & Test

---

## 🔧 Troubleshooting Guide

### Issue 1: Flask vs FastAPI - ASGI/WSGI Mismatch

**Problem:**
```
TypeError: Flask.__call__() missing 1 required positional argument: 'start_response'
```

**Root Cause:** Trying to run Flask (WSGI) with Uvicorn (ASGI server)

**Solution:** Migrated from Flask to FastAPI
```python
# Before (Flask)
from flask import Flask
app = Flask(__name__)

# After (FastAPI)
from fastapi import FastAPI
app = FastAPI()
```

**Learning:** Always match the framework with the correct server type (WSGI vs ASGI)

---

### Issue 2: pip/python3 Not Found in Jenkins

**Problem:**
```
/var/jenkins_home/workspace/devops-project@tmp/durable-f12aaabd/script.sh.copy: 3: pip: not found
```

**Root Cause:** Jenkins container doesn't have Python installed

**Solution:** Run tests inside Docker container instead
```bash
docker build -t ${IMAGE_NAME}:test-${IMAGE_TAG} .
docker run --rm ${IMAGE_NAME}:test-${IMAGE_TAG} python3 -m pytest -v
```

**Learning:** Use Docker for consistent build environments

---

### Issue 3: Docker Permission Denied in Jenkins

**Problem:**
```
docker: Permission denied
```

**Root Cause:** Jenkins user doesn't have Docker socket permissions

**Solution:**
```bash
docker exec -u root jenkins apt-get update && apt-get install -y docker.io
docker exec -u root jenkins usermod -aG docker jenkins
docker restart jenkins
```

**Learning:** Container needs proper permissions to access Docker socket

---

### Issue 4: kubectl Not Found

**Problem:**
```
kubectl: not found
```

**Root Cause:** kubectl not installed in Jenkins container

**Solution:**
```bash
docker exec -u root jenkins sh -c "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/"
```

**Learning:** Install all required tools in CI/CD environment

---

### Issue 5: kubectl Can't Connect to Cluster

**Problem:**
```
error validating data: failed to download openapi: Authentication required
```

**Root Cause:** 
1. Kubeconfig pointing to localhost (127.0.0.1)
2. Jenkins container not on kind network

**Solution:**
```bash
# Copy kubeconfig
docker cp %USERPROFILE%\.kube\config jenkins:/var/jenkins_home/.kube/config

# Update server URL
docker exec jenkins kubectl config set-cluster kind-kind --server=https://kind-control-plane:6443 --insecure-skip-tls-verify=true

# Connect Jenkins to kind network
docker network connect kind jenkins
```

**Learning:** Containers need network connectivity and proper kubeconfig

---

### Issue 6: Pytest Module Not Found in Docker

**Problem:**
```
/usr/local/bin/python3: No module named pytest
```

**Root Cause:** Multi-stage Docker build not copying installed packages

**Solution:** Update Dockerfile to copy site-packages
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY app/ .
```

**Learning:** Multi-stage builds need explicit copying of dependencies

---

### Issue 7: Pytest Can't Find Test Files

**Problem:**
```
ERROR: file or directory not found: app/
```

**Root Cause:** Working directory already in /app, path was wrong

**Solution:** Run pytest without app/ prefix
```bash
docker run --rm ${IMAGE_NAME}:test python3 -m pytest -v
```

**Learning:** Understand Docker WORKDIR context

---

### Issue 8: Deployment Manifest Modified by sed

**Problem:** Subsequent builds fail because IMAGE_TAG already replaced

**Root Cause:** `sed -i` modifies file in place

**Solution:** Use temporary file
```bash
cp k8s/deployment.yaml k8s/deployment-temp.yaml
sed -i "s|IMAGE_TAG|${IMAGE_TAG}|g" k8s/deployment-temp.yaml
kubectl apply -f k8s/deployment-temp.yaml
rm k8s/deployment-temp.yaml
```

**Learning:** Never modify source files in CI/CD, use copies

---

### Issue 9: Can't Access Application via Ingress

**Problem:** http://devops-app.local not accessible

**Root Cause:** DNS not configured for local domain

**Solution:** Use port-forward instead
```bash
kubectl port-forward svc/devops-app 5000:80
```
Access: http://localhost:5000

**Learning:** Local development needs port-forwarding or hosts file modification

---

### Issue 10: DockerHub Credentials Not Found

**Problem:**
```
ERROR: Could not find credentials entry with ID 'dockerhub-creds'
```

**Root Cause:** Jenkins credentials not configured

**Solution:**
1. Jenkins → Manage Jenkins → Manage Credentials
2. Add credentials with ID: `dockerhub-creds`
3. Type: Username with password
4. Enter DockerHub username and password

**Learning:** Always configure credentials before using them in pipeline

---

## 📝 Commands Reference

### Docker Commands

```bash
# Build image
docker build -t jaga9989/devops-project:latest .

# Run container
docker run -d -p 5000:5000 jaga9989/devops-project:latest

# Push to registry
docker push jaga9989/devops-project:latest

# List containers
docker ps

# View logs
docker logs <container-id>

# Execute command in container
docker exec -it <container-id> bash

# Remove container
docker rm -f <container-id>

# Remove image
docker rmi jaga9989/devops-project:latest
```

### Kubernetes Commands

```bash
# Get resources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get ingress

# Describe resource
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow logs

# Port forward
kubectl port-forward svc/devops-app 5000:80

# Apply manifests
kubectl apply -f k8s/deployment.yaml

# Delete resources
kubectl delete -f k8s/deployment.yaml

# Scale deployment
kubectl scale deployment devops-app --replicas=3

# Rollout status
kubectl rollout status deployment/devops-app

# Rollback deployment
kubectl rollout undo deployment/devops-app

# Get events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Kind Commands

```bash
# Create cluster
kind create cluster --config kind-config.yaml

# List clusters
kind get clusters

# Delete cluster
kind delete cluster

# Load image to cluster
kind load docker-image jaga9989/devops-project:latest

# Get kubeconfig
kind get kubeconfig > ~/.kube/config
```

### Git Commands

```bash
# Initialize repository
git init

# Add files
git add .
git add <file-name>

# Commit changes
git commit -m "commit message"

# Push to remote
git push origin main

# Pull from remote
git pull origin main

# Check status
git status

# View history
git log --oneline

# Create branch
git checkout -b feature-branch

# Switch branch
git checkout main
```

### Jenkins Commands

```bash
# Get initial password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Restart Jenkins
docker restart jenkins

# View Jenkins logs
docker logs jenkins

# Backup Jenkins home
docker cp jenkins:/var/jenkins_home ./jenkins_backup
```

---

## 💡 Key Learnings

### 1. CI/CD Pipeline Design
- **Modular Stages:** Break pipeline into clear, independent stages
- **Fail Fast:** Run tests early to catch issues quickly
- **Idempotent:** Pipeline should produce same result on re-run
- **Cleanup:** Always clean up temporary resources

### 2. Docker Best Practices
- **Multi-stage Builds:** Reduce image size and improve security
- **Layer Caching:** Order Dockerfile commands for optimal caching
- **Non-root User:** Run containers as non-root for security
- **Health Checks:** Always include health check endpoints

### 3. Kubernetes Deployment
- **Rolling Updates:** Zero-downtime deployments
- **Resource Limits:** Prevent resource exhaustion
- **Readiness/Liveness Probes:** Ensure application health
- **Labels & Selectors:** Proper resource organization

### 4. Monitoring & Observability
- **Metrics Collection:** Use Prometheus for time-series data
- **Visualization:** Grafana for dashboards
- **Logging:** Centralized log aggregation
- **Alerting:** Proactive issue detection

### 5. Troubleshooting Approach
1. **Read Error Messages:** Carefully analyze error output
2. **Check Logs:** Application, container, and system logs
3. **Verify Connectivity:** Network, DNS, and service discovery
4. **Test Incrementally:** Isolate and test each component
5. **Document Solutions:** Keep track of fixes for future reference

### 6. Local Development
- **Kind for K8s:** Lightweight local Kubernetes
- **Port Forwarding:** Easy access to services
- **Docker Networks:** Container communication
- **Volume Mounts:** Persist data and share files

### 7. Security Considerations
- **Secrets Management:** Never commit credentials
- **Image Scanning:** Check for vulnerabilities
- **RBAC:** Proper access controls
- **Network Policies:** Restrict pod communication

---

## 🚀 Future Enhancements

### Short Term
- [ ] Add SonarQube for code quality analysis
- [ ] Implement automated security scanning (Trivy)
- [ ] Add Slack/Email notifications
- [ ] Create custom Grafana dashboards
- [ ] Add integration tests

### Medium Term
- [ ] Multi-environment support (dev/staging/prod)
- [ ] Blue-Green deployment strategy
- [ ] Canary releases
- [ ] Automated rollback on failure
- [ ] Performance testing with k6

### Long Term
- [ ] GitOps with ArgoCD
- [ ] Service mesh (Istio)
- [ ] Distributed tracing (Jaeger)
- [ ] Log aggregation (ELK stack)
- [ ] Infrastructure as Code (Terraform)
- [ ] Multi-cluster deployment

---

## 📚 Additional Resources

### Documentation
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

### Tutorials
- [Kind Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Jenkins Pipeline Tutorial](https://www.jenkins.io/doc/book/pipeline/)
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)

### Tools
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [kind](https://kind.sigs.k8s.io/)
- [Lens](https://k8slens.dev/) - Kubernetes IDE

---

## 📞 Contact & Support

**Project Maintainer:** Alagani Jagadeesh
**Email:** a.jagadeesh@exafluence.com
**Repository:** https://github.com/Alagani/Devops_Project

---

## 📄 License

This project is for educational purposes.

---

## 🎉 Conclusion

This project demonstrates a complete DevOps pipeline from code commit to production deployment. It covers:
- ✅ Source control with Git
- ✅ Automated testing
- ✅ Containerization with Docker
- ✅ CI/CD with Jenkins
- ✅ Container orchestration with Kubernetes
- ✅ Monitoring and observability
- ✅ Troubleshooting and problem-solving

**Key Takeaway:** DevOps is about automation, collaboration, and continuous improvement. This project provides a solid foundation for building production-ready pipelines.

---

**Last Updated:** January 2025
**Version:** 1.0.0
