pipeline {
  agent any
  stages {
    stage('error') {
      steps {
        parallel(
          "pStep1": {
            echo 'Start pipeline'
            sleep 5
            
          },
          "pStep2": {
            echo 'step2'
            sh 'echo "Step from this pipelie"'
            
          }
        )
      }
    }
    stage('Build step') {
      steps {
        sh 'sleep 120'
      }
    }
    stage('Start app') {
      steps {
        sh 'sleep 30'
      }
    }
    stage('Deploy app confirmation') {
      steps {
        input(message: 'Approve', ok: 'Yes. Deploy this into production')
      }
    }
  }
}