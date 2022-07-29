pipeline {
    agent any

    stages {
        // The first 3 stages should run regardless of what triggered the change
        stage('Set the environment') {
            when {
                    anyOf {
                        branch 'main';
                        branch 'develop'
                    }

                }
            steps {                
                script {
                    echo "** Branch: $BRANCH_NAME**"
                    if (env.BRANCH_NAME == 'main') {
                        env.GCP_ENV = 'production'
                    } else if (env.BRANCH_NAME == 'develop') {
                        env.GCP_ENV = 'develop'
                    } else {
                        env.GCP_ENV = "N/A"
                    }
                }
            }
        }
        stage('installing dependencies') {
            steps {
                echo 'installing dependencies'
                cd source/
                sh 'python3 -m pip install -r requirements.txt'
            }
        }
        stage('Test') {
            steps {
                echo 'running tests'
                cd source/
                sh 'python3 -m pytest'
            }
        }
        // code is built only when a tag is pushed to github
        stage('Build code') {
            when { expression { sh([returnStdout: true, script: 'echo $TAG_NAME | tr -d \'\n\'']) } }
            steps {
                echo 'Building application code'
                sh "docker build -t -f ./build/docker/Dockerfile europe-docker.pkg.dev/single-planet-357417/docstorage/docstorage:$TAG_NAME ."
                sh "docker push europe-docker.pkg.dev/single-planet-357417/docstorage/docstorage:$TAG_NAME"
            }
        }
        // perform a terraform plan 
        stage('Perform a terraform plan') {
            steps {
                echo 'Perform a terraform plan'
                dir('deploy/terraform') {
                    sh "./runtf.sh $GCP_ENV N"
                }
            }
        }

        //deploy
        stage('Deploy infrastructure') {
            when {
                    anyOf {
                        branch 'main';
                        branch 'develop'
                    }

                }
            steps {
                echo 'Perform a terraform apply'
                dir('deploy/terraform') {
                    sh "./runtf.sh $GCP_ENV Y"
                }
            }
        }
    }
}