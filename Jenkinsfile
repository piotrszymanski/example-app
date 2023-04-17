pipeline {
    agent {
        label 'iaccess-builder'
    }

    environment {
        APP_NAME = 'example-app'
        APP_HOSTNAME = "${env.APP_NAME}.webclient-docker.cphdev.deltek.com"
        IMAGE_REPOSITORY = "temporary"
        IMAGE_NAME = "${env.IMAGE_REPOSITORY}.artifactory.cphdev.deltek.com/mobile-test-app:${env.APP_NAME}-${env.GIT_COMMIT.substring(0,7)}"
    }

    stages {
        stage('Build environment') {
            agent {
                docker { 
                    image 'maconomy-dev.artifactory.cphdev.deltek.com/webclient-build-env:node_18-613940'
                    label 'iaccess-builder'
                    args '-e HOME=${WORKSPACE}'
                    reuseNode true
                }
            }

            stages {
                stage('Install') {
                    steps {
                        sh 'npm install'
                    }
                }

                stage('Test app') {
                    steps {
                        sh 'npx ng test --watch=false --browsers ChromeHeadlessCI'
                    }
                }

                stage('Build app') {
                    steps {
                        sh 'npx ng build --configuration production --output-path dist/'
                    }
                }
            }
        }

        stage('Build image') {
            steps {
                script {
                    def image = docker.build(env.IMAGE_NAME, "--no-cache .")
                }
            }
        }

        stage('Upload image') {
            steps {
                script {
                    rtDockerPush(
                      serverId: 'artifactory.cphdev.deltek.com',
                      targetRepo: env.IMAGE_REPOSITORY,
                      image: env.IMAGE_NAME
                    )
                }
            }
        }

        stage('Deploy image') {
            agent {
                label 'webclient-swarm'
            }

            steps {
                sh "docker stack deploy -c docker-compose.yml ${APP_NAME}"
            }
        }
    }

    post {
        always {
            // Clean after build
            cleanWs()

            // Send out status emails
            step([$class: 'Mailer',
                notifyEveryUnstableBuild: true,
                recipients: emailextrecipients([[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']])])
        }
    }
}
