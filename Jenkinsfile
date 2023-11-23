pipeline {
    environment {
        dockerImage = ''
        registry = "kumard31/numeric-app"
        registryCredential = kumard31
    }

    agent any
    
    stages {
        stage ("build stage") {
            steps {
                sh "mvn clean package -DskipTests=True"
                archive "target/*.jar"
            }
        }

        stage('Unit Tests - JUnit and Jacoco') {
            steps {
                sh "mvn test"
            }
            post {
                always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }

        stage ("docker build and push stage") {
            steps {
                docker.withRegistry('', 'kumard31') {
                    sh 'printenv'
                    dockerImage = docker.build registry + ":$GIT_COMMIT"
                    Image.push(registry + ":$GIT_COMMIT")
                }
            }
        }
    }
}
