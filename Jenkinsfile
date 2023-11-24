pipeline {
    environment {
        dockerImage = ''
        registry = "kumard31/numeric-app"
        registryCredential = 'kumard31'
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
                script {
                    docker.withRegistry('', 'kumard31') {
                        sh 'printenv'
                        def dockerImage = docker.build registry + ":$GIT_COMMIT"
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Kubernetes Deployment - DEV') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    echo "image name: ${dockerImage}"
                    sh "sed -i 's#replace#kumard31/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                    sh "kubectl apply -f k8s_deployment_service.yaml"
                }
            }
        }

        stage('Remove Unused docker image') {
            steps{
                sh "docker rmi $registry:$GIT_COMMIT"
            }
        }
    }
}
