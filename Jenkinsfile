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

         stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'

                    withSonarQubeEnv('SonarQube') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=wordpress-devops \
                            -Dsonar.projectName=wordpress-devops \
                            -Dsonar.sources=.
                        """
                    }
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'wordpress-devops-salif' 
                }
            } 
        }
        stage('Docker Build') {
            steps {
                script {
                    sh '''
                        docker compose -f docker-compose.yml build
                    '''
                }
            }
        }
        stage('Security Scan') {
            steps {
                sh "trivy image wordpress-devops || true"
            }
        }

        stage('Deploy') {
            steps {
                sh "docker compose -f docker-compose.yml up -d"
            }
        }
    }
}
