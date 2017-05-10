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
        sh './build.sh'
      }
    }
    stage('Start app') {
      steps {
        sh './app.sh'
      }
    }
    stage('Deploy app confirmation') {
      steps {
        input(message: 'Deploy to UAT', ok: 'NOTOK')
      }
    }
  }
}