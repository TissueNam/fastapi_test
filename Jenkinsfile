pipeline {
  agent any
  environment {
    REGION     = "ap-northeast-2"
    ACCOUNT_ID = "792126555894"
    REPO       = "fastapi-test"
    ECR_URI    = "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}"
    IMAGE_TAG  = "${env.BUILD_NUMBER}"
  }
  options { timestamps() }
  triggers { pollSCM("H/2 * * * *") } // 웹훅 없으면 2분마다 체크

  stages {
    stage("Checkout") {
      steps { checkout scm }
    }

    stage("Build Docker Image") {
      steps {
        sh """
          docker build -t ${ECR_URI}:${IMAGE_TAG} .
          docker tag ${ECR_URI}:${IMAGE_TAG} ${ECR_URI}:latest
        """
      }
    }

    stage("Login & Push to ECR") {
      environment {
        AWS_ACCESS_KEY_ID     = credentials("aws-access-key-id")
        AWS_SECRET_ACCESS_KEY = credentials("aws-secret-access-key")
      }
      steps {
        sh """
          aws ecr get-login-password --region ${REGION} \
          | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

          docker push ${ECR_URI}:${IMAGE_TAG}
          docker push ${ECR_URI}:latest
        """
      }
    }

    // --- (나중에 EC2 준비되면 이 블록 주석 해제) ---
    // stage("Deploy to EC2") {
    //   steps {
    //     sshagent(credentials: ["ec2-ssh-key"]) {
    //       sh '''
    //         ssh -o StrictHostKeyChecking=no ec2-user@<EC2_PUBLIC_IP> \
    //           ACCOUNT_ID=${ACCOUNT_ID} REPO=${REPO} REGION=${REGION} /usr/local/bin/deploy.sh
    //       '''
    //     }
    //   }
    // }

    // stage("Smoke Test (optional)") {
    //   steps { sh "curl -fsS http://<EC2_PUBLIC_IP>/health | grep -q '\"status\":\"ok\"'" }
    // }
  }

  post {
    success { echo "✅ ECR push done" }
    failure { echo "❌ Failed — check logs" }
  }
}
