pipeline {
  agent any

  parameters {
    string(
      name: 'ENVIRONMENT',
      defaultValue: 'dev',
      description: 'Environment directory under terraform/_vars to deploy (dev, staging, prod)'
    )
  }

  environment {
    AWS_DEFAULT_REGION    = 'ap-south-1'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir('terraform') {
          sh 'terraform init -input=false'
        }
      }
    }

    stage('Terraform Workspace') {
      steps {
        dir('terraform') {
          sh 'terraform workspace select ${ENVIRONMENT} 2>/dev/null || terraform workspace new ${ENVIRONMENT}'
        }
      }
    }

    stage('Prepare DB Password') {
      steps {
        script {
          if (!env.TF_VAR_db_password && env.DB_PASSWORD) {
            env.TF_VAR_db_password = env.DB_PASSWORD
            echo 'Using the RDS password from the DB_PASSWORD environment variable'
          }
        }
      }
    }

    stage('Terraform Validate') {
      steps {
        dir('terraform') {
          sh 'terraform validate'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir('terraform') {
          sh '''
            set -e
            args=""
            for file in _vars/${ENVIRONMENT}/*.tfvars; do
              args="$args -var-file=$file"
            done
            echo "Running: terraform plan $args"
            terraform plan -input=false -out=tfplan $args
          '''
        }
      }
    }

    stage('Terraform Apply') {
      input {
        message "Apply Terraform changes to the ${ENVIRONMENT} environment?"
        ok 'Apply'
      }
      steps {
        dir('terraform') {
          sh 'terraform apply -input=false tfplan'
        }
      }
    }

    stage('Destroy') {
      input {
        message "Destroy the ${ENVIRONMENT} environment? This is destructive and cannot be undone."
        ok 'Destroy'
      }
      steps {
        dir('terraform') {
          sh '''
            set -e
            args=""
            for file in _vars/${ENVIRONMENT}/*.tfvars; do
              args="$args -var-file=$file"
            done
            terraform destroy -input=false -auto-approve $args
          '''
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline completed successfully for ${ENVIRONMENT}"
    }
    failure {
      echo "Pipeline failed for ${ENVIRONMENT} - check the logs"
    }
  }
}
