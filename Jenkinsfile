pipeline {
    agent {
        // This spins up a Python container to run your commands
        docker { 
            image 'python:3.9-slim' 
        }
    }

    stages {
        stage('Install & Test') {
            steps {
                // Now 'pip' will work because we are inside the python container
                sh 'pip install --no-cache-dir -r app/requirements.txt'
                sh 'pytest app/'
            }
        }

        stage('Build Docker') {
            // Note: If you run Docker commands inside a Docker agent, 
            // your Jenkins needs "Docker-in-Docker" or a socket mount.
            steps {
                sh 'docker build -t alagani/python-devops:${BUILD_NUMBER} .'
            }
        }
    }
}
