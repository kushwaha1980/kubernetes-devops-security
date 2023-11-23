pipeline {
    agent any
    
    stages {
        stage ("build stage") {
            step {
                sh "mvn clean package -DskipTests=True"
                archive "target/*.jar"
            }
        }
    }
}
