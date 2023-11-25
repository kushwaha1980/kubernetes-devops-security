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

        stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
                always {
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh "mvn clean package sonar:sonar \
                        -Dsonar.projectKey=devsecops-numeric-application \
                        -Dsonar.projectName='devsecops-numeric-application' \
                        -Dsonar.host.url=http://mydevsecops.eastus.cloudapp.azure.com:9000 \
                        -Dsonar.token=sqp_d4126647a2a33635193cce29079df0e6ba25c4f1"
                }

                timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
                    def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
                    if (qg.status != 'OK') {
                    error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    }
                }
            }
        }

        stage ("docker build and push stage") {
            steps {
                script {
                    docker.withRegistry('', 'kumard31') {
                        sh 'printenv'
                        dockerImage = docker.build registry + ":$GIT_COMMIT"
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Kubernetes Deployment - DEV') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    echo "image name: ${dockerImage}"
                    sh "sed -i 's#replace#kumard31/numeric-app:$GIT_COMMIT#g' k8s_deployment_service.yaml"
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
