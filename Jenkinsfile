pipeline {
    agent any
    
    stages {
        stage ("build stag test") {
            steps {
                sh "mvn clean package -DskipTests=True"
                archive "target/*.jar"
            }
        }
    }
}
