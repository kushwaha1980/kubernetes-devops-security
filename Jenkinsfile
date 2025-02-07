@Library('slack') _
pipeline {
    environment {
        dockerImage = ''
        registry = "kumard31/numeric-app"
        registryCredential = 'kumard31'
        deploymentName = "devsecops"
        containerName = "devsecops-container"
        serviceName = "devsecops-svc"
        imageName = "kumard31/numeric-app:${GIT_COMMIT}"
        applicationURL = "http://mydevsecops.eastus.cloudapp.azure.com"
        applicationURI = "/increment/99"
    }

    agent any
    
    stages {
        stage ("build artifacts") {
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
                parallel(
                    "Dependency Scan": {
                        sh "mvn dependency-check:check"
                    },
                    "Trivy Scan": {
                        sh "bash trivy-docker-image-scan.sh"
                    },
                    "OPA Conftest": {
                        sh "/usr/local/bin/conftest test --policy opa-docker-security.rego Dockerfile"
                    }
                )
            }
        }

        stage ("docker build and push stage") {
            steps {
                withDockerRegistry([credentialsId: 'kumard31', url: '']) {
                    sh 'printenv'
                    sh "sudo docker build -t ${registry}:${GIT_COMMIT} ."
                    sh "docker push ${registry}:${GIT_COMMIT}"
                }
            }
        }

               // script {
             //       docker.withRegistry('', 'kumard31') {
               //         sh 'printenv'
                 //       dockerImage = docker.build registry + ":$GIT_COMMIT"
                   //     dockerImage.push()
                    //}
                //}
        stage('Vulnerability Scan - Kubernetes') {
            steps {
                parallel(
                    "OPA Scan": {
                        sh '/usr/local/bin/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
                    },
                    "Kubesec Scan": {
                        sh "bash kubesec-scan.sh"
                    },
                    "Trivy Scan": {
                        sh "bash trivy-k8s-scan.sh"
                    }
                )
            }
        }

        stage('Kubernetes Deployment - DEV') {
            steps {
                parallel(
                    "Deployment": {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-deployment.sh"
                        
                        }
                    },
                    "Rollout-status": {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-deployment-rollout-status.sh"
                        }
                    }
                )
            }
        }

        stage('Integration testing - Dev') {
            steps {
                script {
                    try {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash integration-test.sh"
                        }
                    } catch (e) {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "kubectl -n default rollout undo deploy ${deploymentName}"
                        }
                        throw e
                    }
                }
            }
        }

        stage('OWASP ZAP - DAST') {
            steps {
                sh "bash zap.sh"
            }
        }

        stage('Promote to Prod') {
            steps {
                timeout(time: 2, unit: 'DAYS') {
                    input 'Do you want to approve the deployment to prod env/namespace?'
                }
            }
        }

        stage('k8s-CIS Benchmark') {
            steps {
                script {
                    parallel(
                        "Master": {
                            sh 'bash cis-master.sh'
                        },
                        "etcd": {
                            sh 'bash cis-etcd.sh'
                        },
                        "Kubelet": {
                            sh 'bash cis-node.sh'
                        }
                    )
                }
            }
        }

        stage('Kubernetes Deployment - Prod') {
            steps {
                parallel(
                    "Deployment": {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "sed -i 's#replace#${imageName}#g' k8s_prod_service.yaml"
                            sh "kubectl -n devsecops-istio apply -f k8s_prod_service.yaml"
                        
                        }
                    },
                    "Rollout-status": {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-prod-rollout-status.sh"
                        }
                    }
                )
            }
        }

        stage('Integration Tests - PROD') {
            steps {
                script {
                try {
                    withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh "bash integration-test-PROD.sh"
                    }
                } catch (e) {
                    withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh "kubectl -n prod rollout undo deploy ${deploymentName}"
                    }
                    throw e
                }
                }
            }
        }
        // stage('Remove Unused docker image') {
        //     steps{
        //         sh "docker rmi $registry:$GIT_COMMIT"
        //     }
        // }

    }
    post {
        always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Reports', reportTitles: 'OWASP ZAP HTML Reports', useWrapperFileDirectly: true])
            slackNotification currentBuild.result
        }
    }
}
