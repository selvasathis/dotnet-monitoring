@Library('dpod-test@main') _
pipeline {
    agent any
    environment {
        IMAGE_NAME = 'extraction-schemaagent'
        AWS_REGION = 'us-east-1'
        GIT_URL = 'https://github.com/selvasathis/dotnet-monitoring.git'
        BRANCH = 'test'
        DOCKER_BUILDKIT = '1'
        CREDENTIALS_ID = 'test-token'
        DOCKER_FILE = 'Dockerfile'
        ECR_REPO = 'public.ecr.aws/y9c9p0b6'
        TAG = "qa-v1.${BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') {
            steps {
                script {
                    scmCheckout(
                        gitUrl: env.GIT_URL,
                        branch: env.BRANCH,
                        credentialsId: env.CREDENTIALS_ID
                    )
                }
            }
        }
        // stage('sonar-scanner') {
        //     steps {
        //         sonarScanner(IMAGE_NAME)
        //     }
        // }
        // stage('sonar-quality-gate') {
        //     steps {
        //         sonarQualityGate()
        //     }
        // }
        stage('docker build') {
            steps {
                script {
                    dockerBuild(DOCKER_FILE,IMAGE_NAME)
                }
            }
        }
        // stage('trivy scan docker image') {
        //     steps {
        //         trivyScanImage(IMAGE_NAME)
        //     }
        // }
        stage('docker tag,login and push') {
            steps {
                pushToEcr(IMAGE_NAME)
            }
        }
    }
    post {
        always {
            script {
                def buildStatus = currentBuild.result ?: 'SUCCESS'
                teamsNotification(
                    buildStatus,
                    "${ECR_REPO}/${IMAGE_NAME}",
                    TAG,
                    BRANCH
                )
            }
        }
    }
}
