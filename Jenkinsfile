pipeline {
    agent any

    environment {
        APP_NAME       = 'flask-app'
        IMAGE_NAME     = 'flask-docker-lab'
        IMAGE_TAG      = "${BUILD_NUMBER}"
        CONTAINER_NAME = 'flask-app-prod'
        HOST_PORT      = '5000'
        CONTAINER_PORT = '5000'
    }

    stages {
        stage('Code Checkout') {
            steps {
                echo "Fetching latest source code from repository..."
                checkout scm
            }
        }

        stage('Lint & Unit Test') {
            steps {
                echo "Creating isolated virtual environment for validation..."
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                    
                    echo "Running code quality checks with flake8..."
                    flake8 app/ tests/ --max-line-length=100 --jobs=1
                    
                    echo "Executing pytest suite..."
                    PYTHONPATH=. pytest tests/ -v
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}..."
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                echo "Deploying application container..."
                sh '''
                    if [ $(docker ps -aq -f name=^/${CONTAINER_NAME}$) ]; then
                        echo "Stopping and removing existing container..."
                        docker stop ${CONTAINER_NAME} || true
                        docker rm -f ${CONTAINER_NAME} || true
                    fi
                    
                    echo "Starting new container on port ${HOST_PORT}..."
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p ${HOST_PORT}:${CONTAINER_PORT} \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Post-Deployment Verification') {
            steps {
                echo "Validating application health..."
                sh '''
                    sleep 5
                    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${HOST_PORT}/health)
                    echo "Health check HTTP response: ${HTTP_STATUS}"
                    if [ "$HTTP_STATUS" -ne 200 ]; then
                        echo "Health check failed with status ${HTTP_STATUS}"
                        exit 1
                    fi
                    echo "Deployment verified successfully!"
                '''
            }
        }
    }

    post {
        always {
            echo "Cleaning up temporary workspace files..."
            sh 'rm -rf venv'
        }
        success {
            echo "CI/CD Pipeline Completed Successfully! Application deployed and verified on port ${HOST_PORT}."
        }
        failure {
            echo "Pipeline execution failed. Review console logs above."
        }
    }
}
