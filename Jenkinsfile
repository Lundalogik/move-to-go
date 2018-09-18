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
                powershell '''
                    bundle exec rake release
                '''
            }
        }
    }
    post {
        fixed {
            script {
                if (env.BRANCH_NAME == 'master') {
                    slackSend(message: "Job ${JOB_NAME}:${BUILD_ID} on node ${NODE_NAME} finished successfully. ${BUILD_URL}",
                              botUser: true,
                              color: 'good')
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
                              color: 'danger')
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
