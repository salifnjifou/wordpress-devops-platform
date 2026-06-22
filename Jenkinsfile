pipeline {
    agent any

    environment {
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {

        stage('Test') {
            steps {
                echo "Running tests"
            }
        }

        stage('SonarQube Scan') {
            steps {
                sh """
                sonar-scanner \
                  -Dsonar.projectKey=wordpress-devops \
                  -Dsonar.sources=. \
                  -Dsonar.host.url=https://sonarqube.devopspro.cloud \
                  -Dsonar.login=$SONAR_TOKEN
                """
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t wordpress-devops ."
            }
        }

        stage('Security Scan') {
            steps {
                sh "trivy image wordpress-devops || true"
            }
        }

        stage('Deploy') {
            steps {
                sh "docker compose up -d"
            }
        }
    }
}
