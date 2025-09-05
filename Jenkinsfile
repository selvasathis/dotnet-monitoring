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
    }
    stages {
        stage('Checkout') {
            steps {
                script {
                    teamsNotification("STARTED", env.IMAGE_NAME, env.TAG, env.BRANCH)
                    scmCheckout(
                        gitUrl: env.GIT_URL,
                        branch: env.BRANCH,
                        credentialsId: env.CREDENTIALS_ID
                    )
                }
            }
        }
        stage('sonar-scanner') {
            steps {
              script {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE')
                sonarScanner(IMAGE_NAME)
            }
            }
            post {
                failure {
                    teamsNotification("FAILURE in sonar scan", env.IMAGE_NAME, env.TAG, env.BRANCH)
                }
            }
        }
        stage('sonar-quality-gate') {
            steps {
              script {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE')
                sonarQualityGate()
              }
            }
            post {
                failure {
                    teamsNotification("FAILURE in sonar quality gate", env.IMAGE_NAME, env.TAG, env.BRANCH)
                }
            }
        }
        stage('docker build') {
            steps {
                script {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        dockerBuild(DOCKER_FILE,IMAGE_NAME)
                    }
                }
                }
                post {
                    failure {
                        teamsNotification("FAILURE in Docker Build", env.IMAGE_NAME, env.TAG, env.BRANCH)
                    }
                }
        }
        stage('trivy scan docker image') {
            steps {
                script {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        trivyScanImage(IMAGE_NAME)
                    }
                }
            }
            post {
                failure {
                    teamsNotification("FAILURE in Trivy Scan", env.IMAGE_NAME, env.TAG, env.BRANCH)
                }
            }
        }
        stage('docker tag,login and push') {
            steps {
              script {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                  pushToEcr(IMAGE_NAME)
                }
              }
            }
            post {
                failure {
                    teamsNotification(
                        "FAILURE in Docker Push",
                        "${env.ECR_REPO}/${env.IMAGE_NAME}",
                        env.TAG,
                        env.BRANCH
                    )
                }
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
