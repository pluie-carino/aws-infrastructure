
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t portfolio-website:latest .'
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Docker image built successfully!'
        }
        failure {
            echo 'FAILED: Check the Jenkins Console Output.'
        }
    }
}