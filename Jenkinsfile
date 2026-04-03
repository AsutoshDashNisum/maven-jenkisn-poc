pipeline {
    agent any

    environment {
        // Tag with the Build ID for uniqueness
        IMAGE_NAME = "java-maven-poc"
        IMAGE_TAG = "${env.BUILD_ID}"
        DOCKER_HUB_USER = credentials('docker-hub-user') 
        DOCKER_HUB_PASS = credentials('docker-hub-pass') 
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test (Maven)') {
            steps {
                echo 'Building and testing with Maven using Docker...'
                // Maven is installed natively on the Jenkins agent now!
                sh "mvn clean package"
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Image with Docker Plugin...'
                // Using standard shell instead of docker plugin groovy methods to prevent missing property errors
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                echo 'Scanning image for vulnerabilities...'
                // Using Docker-in-Docker to run Trivy without local install
                sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                    aquasec/trivy:latest image --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Push to Registry') {
            steps {
                echo 'Logging in and pushing to Docker Hub...'
                sh "echo $DOCKER_HUB_PASS | docker login -u $DOCKER_HUB_USER --password-stdin"
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Deploy (CD)') {
            steps {
                echo 'Deploying to Local Machine...'
                sh "docker stop web-app-poc || true"
                sh "docker rm web-app-poc || true"
                sh "docker run -d --name web-app-poc -p 8080:8080 ${IMAGE_NAME}:${IMAGE_TAG}"
                echo "App is live at http://localhost:8080"
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Build ${env.BUILD_ID} deployed successfully!"
        }
        failure {
            echo "FAILURE: Build ${env.BUILD_ID} failed at some stage."
        }
    }
}
