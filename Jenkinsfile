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
        }

        stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh "mvn clean package sonar:sonar \
                        -Dsonar.projectKey=devsecops-numeric-application \
                        -Dsonar.projectName='devsecops-numeric-application' \
                        -Dsonar.host.url=http://mydevsecops.eastus.cloudapp.azure.com:9000"
                }

                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Vulnerability Scan - Docker ') {
            steps {
                sh "mvn dependency-check:check"
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
    post {
        always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
    }
}
