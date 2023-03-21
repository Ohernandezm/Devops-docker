pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        IMAGE_REPO_NAME = 'devops-repository'
        IMAGE_TAG = 'latest'
        REPOSITORY_URI_ECR = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}" 
        BRANCH_NAME = "${GIT_BRANCH.split('/')[1]}"
        EKS_NAME = 'eks-cluster-devops-obligatorio'
        NAMESPACE = 'dev'
        VERSION = readMavenPom().getVersion()
        IMAGE = readMavenPom().getArtifactId()
    }
    tools {
        maven 'Maven 3.8.6'
    }
    stages {
        stage ('Initialize') {
            steps {
                script { 
                    switch (env.BRANCH_NAME) {                    
                    case 'develop':
                            NAMESPACE = 'dev'
                            break
                    case 'master':                            
                            NAMESPACE = 'prod'
                            break
                    case 'test':                            
                            NAMESPACE = 'test'
                            break
                    }
                }
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -f pom.xml clean package'
            }
        }
        stage('SonarQube analysis') {
            environment {
                SCANNER_HOME = tool 'Sonar-scanner'
            }
            steps {
                withSonarQubeEnv(credentialsId: '1', installationName: 'sonarqube') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectKey=projectKey \
                    -Dsonar.projectName=orders-service-example \
                    -Dsonar.sources=src/ \
                    -Dsonar.java.binaries=target/classes/ \
                    -Dsonar.exclusions=src/test/java/****/*.java \
                    -Dsonar.projectVersion=${BUILD_NUMBER}-${GIT_COMMIT_SHORT}'''
                }
            }
        }
        stage('SQuality Gate') {
            steps {
                sleep(60)
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Build docker image') {
            steps { 
                sh 'sudo aws ecr get-login --region us-east-1 --no-include-email > docker_login.sh && sh docker_login.sh'
                sh "docker build --build-arg JAR_FILE=/target/${IMAGE}-${VERSION}.jar -t ${IMAGE_REPO_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI_ECR}:${IMAGE_TAG}"
                sh "docker push ${REPOSITORY_URI_ECR}:${IMAGE_TAG}"
            }
        }
        stage('Deploy ') {
            steps {
                sh "aws eks --region us-east-1 update-kubeconfig --name ${EKS_NAME}"
                sh 'kubectl apply -f namespaces.yaml'
                sh "sed -e s#{{IMAGE_NAME}}#${REPOSITORY_URI_ECR}:${IMAGE_TAG}#g -e s#{{NAMESPACE}}#${NAMESPACE}#g orders-service-deployment.yaml | kubectl apply -f -" // sh 'kubectl apply -f orders-service-deployment.yaml'
                sh "sed s#{{NAMESPACE}}#${NAMESPACE}#g orders-service-service.yaml | kubectl apply -f -"
            }
        }
    } 
}
