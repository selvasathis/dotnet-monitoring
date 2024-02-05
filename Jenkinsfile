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
                    sh "trivy fs . > trivyfsreport.txt"
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
        stage ('docker build') {
            steps {
                script {
                    sh 'docker build -t secops .'
                    sh 'docker tag secops:latest 267765472985.dkr.ecr.ap-northeast-1.amazonaws.com/secops:latest'
                }
            }
        }
        stage ('image scan') {
            steps {
                script {
                    sh 'trivy image 267765472985.dkr.ecr.ap-northeast-1.amazonaws.com/secops:latest > trivyimagereport.txt'
                }
            }
        }
        stage ('docker login and push') {
            steps {
                script {
                    sh 'aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 267765472985.dkr.ecr.ap-northeast-1.amazonaws.com'
                    sh 'docker push 267765472985.dkr.ecr.ap-northeast-1.amazonaws.com/secops:latest'
                }
            }
        }
        // stage ('remove all the images') {
        //     steps {
        //         script {
        //             sh 'docker rmi 267765472985.dkr.ecr.ap-northeast-1.amazonaws.com/secops:latest secops:latest' 
        //     }
        // }
        // }
        stage ('docker run') {
            steps {
                script {
                    sh 'docker run -itd --name dotnetmonitering-app -p 8090:80 267765472985.dkr.ecr.ap-northeast-1.amazonaws.com/secops:latest'
                }
            }
        }
    }
}
