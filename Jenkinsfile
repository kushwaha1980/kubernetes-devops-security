pipeline {
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
                docker.withRegistry('https://registry.hub.docker.com', 'kumard31') {
                    sh 'printenv'
                    sh 'docker build -t kumard31/numeric-app:""$GIT_COMMIT"" .'
                    sh 'docker push kumard31/numeric-app:""$GIT_COMMIT""'
                }
            }
        }
    }
}
