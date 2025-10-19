pipeline {
    agent any

    tools {
        nodejs "NodeJS_18"
    }

    environment {
        DOCKER_HUB_USER = 'abdoubasse'
        FRONT_IMAGE = 'react-frontend'
        BACKEND_IMAGE = 'express-backend'
        KUBECONFIG = '/var/lib/jenkins/.minikube/config'
    }

    triggers {
        GenericTrigger(
            genericVariables: [
                [key: 'ref', value: '$.ref'],
                [key: 'pusher_name', value: '$.pusher.name'],
                [key: 'commit_message', value: '$.head_commit.message']
            ],
            causeString: 'Push par $pusher_name sur $ref: "$commit_message"',
            token: 'mywebhook',
            printContributedVariables: true,
            printPostContent: true
        )
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/AbdouBasse/pipeline.git'
            }
        }

        stage('Install dependencies - Backend') {
            steps {
                dir('back') {
                    sh 'npm install'
                }
            }
        }

        stage('Install dependencies - Frontend') {
            steps {
                dir('front') {
                    sh 'npm install'
                }
            }
        }

        // ----------------------------
        // SonarQube (commenté volontairement)
        // ----------------------------
      /*
        stage('SonarQube Analysis') {
            steps {
                echo "Analyse du code avec SonarQube"
                withSonarQubeEnv('Sonarqube_local') {
                    withCredentials([string(credentialsId: 'credentials_sonarqube', variable: 'SONAR_TOKEN')]) {
                        sh """
                            ${tool('Sonarqube_scanner')}/bin/sonar-scanner \
                            -Dsonar.projectKey=sonarqube \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=$SONAR_HOST_URL \
                            -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
        }

        stage("Quality Gate") {
            steps {
                echo "Vérification du Quality Gate"
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate(abortPipeline: true)
                }
            }
        }
        */

        // ----------------------------
        // Tests
        // ----------------------------
      //  stage('Run tests') {
       //     steps {
       //         script {
                //    sh 'cd back && npm test || echo "Aucun test backend"'
                 //   sh 'cd front && npm test || echo "Aucun test frontend"'
           //     }
       //     }
       // }

        // ----------------------------
        // Docker
        // ----------------------------
        stage('Build Docker Images') {
            steps {
                script {
                    sh """
                    docker build -t $DOCKER_HUB_USER/$FRONT_IMAGE:latest \
                    --build-arg VITE_API_URL=http://myapp.local/api ./front
                    """
                    sh "docker build -t $DOCKER_HUB_USER/$BACKEND_IMAGE:latest ./back"
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'credentials_dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $DOCKER_USER/$FRONT_IMAGE:latest
                        docker push $DOCKER_USER/$BACKEND_IMAGE:latest
                    '''
                }
            }
        }

        stage('Clean Docker') {
            steps {
                sh 'docker container prune -f'
                sh 'docker image prune -f'
            }
        }

        // ----------------------------
        // Kubernetes
        // ----------------------------
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'credentials_kubernetes']) {
                    sh "kubectl apply -f k8s/mongo-deployment.yaml"
                    sh "kubectl apply -f k8s/mongo-service.yaml"
                    sh "kubectl apply -f k8s/back-deployment.yaml"
                    sh "kubectl apply -f k8s/back-service.yaml"
                    sh "kubectl apply -f k8s/front-deployment.yaml"
                    sh "kubectl apply -f k8s/front-service.yaml"

                    sh "kubectl rollout status deployment/mongo"
                    sh "kubectl rollout status deployment/backend"
                    sh "kubectl rollout status deployment/frontend"
                }
            }
        }

        // ----------------------------
        // Smoke Test (optionnel)
        // ----------------------------
        /*
        stage('Smoke Test') {
            steps {
                sh '''
                    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
                    FRONT_PORT=$(kubectl get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}')
                    BACK_PORT=$(kubectl get service backend-service -o jsonpath='{.spec.ports[0].nodePort}')

                    FRONT_URL=http://$NODE_IP:$FRONT_PORT
                    BACK_URL=http://$NODE_IP:$BACK_PORT

                    curl -f $FRONT_URL || echo "Frontend unreachable"
                    curl -f $BACK_URL/api || echo "Backend unreachable"
                '''
            }
        }
        */
    }

    post {
        success {
            emailext(
                subject: "Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Pipeline réussi\nDétails : ${env.BUILD_URL}",
                to: "abdoubasseoconoor@gmail.com"
            )
        }
        failure {
            emailext(
                subject: "Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a échoué\nDétails : ${env.BUILD_URL}",
                to: "abdoubasseoconoor@gmail.com"
            )
        }
    }
}
