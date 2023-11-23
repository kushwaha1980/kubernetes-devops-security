pipeline {
    agent any
    
    stages {
        stage ("build stagee") {
            steps {
                sh "mvn clean package -DskipTests=True"
                archive "target/*.jar"
            }
        }
    }
}
