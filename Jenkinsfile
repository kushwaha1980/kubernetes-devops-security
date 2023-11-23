pipeline {
    agent any
    
    stages {
        stage ("build stagee") {
            step {
                sh "mvn clean package -DskipTests=True"
                archive "target/*.jar"
            }
        }
    }
}
