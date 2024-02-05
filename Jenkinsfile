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
        stage ('quality gate') {
            steps {
                script {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                        error "Pipeline aborted due to Quality Gate failure: ${qg.status}"
                    }
                    echo "code ok"
                }
            }
        }
        stage ('trivy scan file') {
            steps {
                script {
                    sh "trivy fs . > trivyreport.txt"
                }
            }
        }
        stage ('owasp depentancy check'){
            steps {
                script {
                    dependencyCheck additionalArguments: '--scan ./ --format XML ', odcInstallation: 'new'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                }
            }
        }
    }
}
