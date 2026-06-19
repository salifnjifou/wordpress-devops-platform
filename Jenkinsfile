pipeline {

agent any


environment {

SONAR_TOKEN = credentials('sonar-token')

}


stages {


stage('Checkout') {

steps {

git 'YOUR_GITLAB_REPO'

}

}


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
-Dsonar.sources=.

"""

}

}


stage('Docker Build') {

steps {

sh """

docker build \
-t wordpress-devops .

"""

}

}


stage('Security Scan') {

steps {

sh """

trivy image wordpress-devops

"""

}

}


stage('Deploy') {

steps {

sh """

docker compose up -d

"""

}

}


}


}