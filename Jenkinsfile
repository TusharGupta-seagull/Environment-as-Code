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
          // Each ENVIRONMENT maps to a Terraform workspace so environments
          sh 'terraform workspace select ${ENVIRONMENT} 2>/dev/null || terraform workspace new ${ENVIRONMENT}'
        }
      }
    }

    stage('Prepare DB Password') {
      steps {
        script {
          // RDS password precedence (see terraform/variables.tf `db_password`):
          //   1. TF_VAR_db_password — set it on the Jenkins agent (export it in
          //      /etc/environment, a Jenkins global env var, or fetch it from Vault
          //      below). Terraform reads it straight from the environment.
          //   2. db_password_ssm_parameter — an existing SSM SecureString param.
          //   3. Terraform generates a random password and stores it in SSM.
          if (!env.TF_VAR_db_password && env.DB_PASSWORD) {
            env.TF_VAR_db_password = env.DB_PASSWORD
            echo 'Using the RDS password from the DB_PASSWORD environment variable'
          }
          // Vault alternative: fetch the password from Vault and export it as
          // TF_VAR_db_password before the Terraform stages below, e.g. with the
          // Jenkins Vault plugin:
          //   withVault([configuration: [engineVersion: 2], vaultUrl: '...',
          //              vaultCredentialId: 'vault-token']) {
          //     env.TF_VAR_db_password = sh(returnStdout: true,
          //       script: 'vault kv get -field=password secret/eac/dev/db').trim()
          //   }
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
