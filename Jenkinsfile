pipeline {
    agent any
    tools {
        jdk 'jdk17'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage('git checkout') {
            steps {
                script {
                    // Assuming you have the credentials configured in Jenkins and 'github-tocken' is the ID
                    git branch: 'main', credentialsId: 'github-tocken', url: 'https://github.com/selvasathis/dotnet-monitoring.git'
                }
            }
        }
        stage('sonar-scanner') {
            steps {
                script {
                    withSonarQubeEnv('sonar-server') {
                        // Assuming 'sonar.projectKey' and 'sonar.projectName' are configured properly
                        sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=dotnet-monitoring -Dsonar.projectKey=dotnet-monitoring"
                    }
                }
            }
        }
    }
}
