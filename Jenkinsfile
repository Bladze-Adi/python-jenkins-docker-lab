pipeline {
    agent any
    environment {
        IMAGE_NAME     = "python-flask-app"
        IMAGE_TAG      = "${BUILD_NUMBER}"
        CONTAINER_NAME = "python-flask-prod"
        HOST_PORT      = "5000"
        CONTAINER_PORT = "5000"
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
                    flake8 app/ --max-line-length=100 --jobs=1
                    
                    echo "Executing unit tests with pytest..."
                    PYTHONPATH=. pytest tests/ -v
                '''
            }
        }
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}..."
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
                '''
            }
        }
        stage('Deploy Container') {
            steps {
                echo "Deploying Docker container..."
                sh '''
                    # Stop and remove existing container if running
                    if [ $(docker ps -aq -f name=${CONTAINER_NAME}) ]; then
                        echo "Stopping and removing existing container..."
                        docker stop ${CONTAINER_NAME} || true
                        docker rm -f ${CONTAINER_NAME} || true
                    fi
                    # Run new container instance
                    echo "Starting new container on port ${HOST_PORT}..."
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p ${HOST_PORT}:${CONTAINER_PORT} \
                        ${IMAGE_NAME}:latest
                '''
            }
        }
        stage('Post-Deployment Verification') {
            steps {
                echo "Verifying application availability..."
                sh '''
                    sleep 5
                    curl --fail http://localhost:${HOST_PORT}/health || exit 1
                    echo "Deployment successfully verified!"
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
            echo "Pipeline executed successfully! Application is live."
        }
        failure {
            echo "Pipeline execution failed. Review console logs above."
        }
    }
}
