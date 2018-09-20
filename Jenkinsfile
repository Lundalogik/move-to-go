#!/usr/bin/env groovy

pipeline {
    agent { label 'jenkins-slave-windows'}
    options { 
        timestamps() 
    }

    stages {

        stage('Install tooling') {
            steps {
                powershell '''
                    bundle install 
                '''
            }
        }

        stage('Tools unit tests') {
            steps {
                powershell '''
                    bundle exec rake spec
                '''
            }
        }

        stage('Release gem') {
            when {
                branch 'master'
            }
            steps {
                configFileProvider([configFile(fileId: 'gem_credentials', targetLocation: 'c:\\Users\\Administrator\\.gem\\credentials')]) {
                    script {
                        try {
                            powershell 'bundle exec gem release'
                        } catch (error) {
                            echo error
                            echo "Failed to release (was it a republish ignore issue)"
                        }
                    }
                }
            }
        }
    }
    post {
        fixed {
            script {
                if (env.BRANCH_NAME == 'master') {
                    slackSend(message: "Job ${JOB_NAME}:${BUILD_ID} on node ${NODE_NAME} finished successfully. ${BUILD_URL}",
                              botUser: true,
                              color: 'good',
                              channel: '#go-dev')
                } else if (env.BRANCH_NAME.startsWith('PR')) {
                    slackSend(message: "Job ${JOB_NAME}:${BUILD_ID} on node ${NODE_NAME} finished successfully. ${BUILD_URL}",
                              botUser: true,
                              color: 'good')
                }
            }
        }

        regression {
            script {
                if (env.BRANCH_NAME == 'master') {
                    slackSend(message: "Job ${JOB_NAME}:${BUILD_ID} on node ${NODE_NAME} failed. ${BUILD_URL}",
                              botUser: true,
                              color: 'danger',
                              channel: '#go-dev')
                } else if (env.BRANCH_NAME.startsWith('PR')) {
                    slackSend(message: "Job ${JOB_NAME}:${BUILD_ID} on node ${NODE_NAME} failed. ${BUILD_URL}",
                              botUser: true,
                              color: 'danger')
                }
            }
        }

        cleanup {
            step([$class: 'WsCleanup'])
        }
    }
}
