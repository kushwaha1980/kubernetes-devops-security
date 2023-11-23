pipeline {
    agent any
    
    stages {
        stage ("build stag") {
            steps {
                sh "mvn clean package -DskipTests=True"
                archive "target/*.jar"
            }
        }
    }
}
