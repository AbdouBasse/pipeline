parameters {
    booleanParam(name: 'APPLY_INFRA', defaultValue: false, description: 'Appliquer terraform apply ?')
}

pipeline {
    agent any

    environment {
        PATH = "/usr/local/bin:$PATH"
        AWS_DEFAULT_REGION = 'us-west-2'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        credentialsId: 'github-jenkins',
                        url: 'https://github.com/ndiayekhardiata2024/Depot_Jenkins.git'
                    ]]
                )
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    ),
                    string(
                        credentialsId: 'aws-session-token',
                        variable: 'AWS_SESSION_TOKEN'
                    )
                ]) {
                    dir('infra') {
                        sh '''
                            terraform init
                            terraform plan -var-file=terraform.tfvars
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    ),
                    string(
                        credentialsId: 'aws-session-token',
                        variable: 'AWS_SESSION_TOKEN'
                    )
                ]) {
                    dir('infra') {
                        sh '''
                            terraform apply -auto-approve -var-file=terraform.tfvars
                        '''
                    }
                }
            }
        }
    }
}
