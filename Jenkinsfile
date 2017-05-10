pipeline {
  agent any
  stages {
    stage('error') {
      steps {
        parallel(
          "Start": {
            echo 'Start pipeline'
            sleep 5
            
          },
          "Start2": {
            echo 'step2'
            sh 'echo "Step from this pipelie"'
            
          }
        )
      }
    }
    stage('Build') {
      steps {
        sh './build.sh'
      }
    }
    stage('Start') {
      steps {
        sh './app.sh'
      }
    }
    stage('Deploy?') {
      steps {
        input(message: 'Deploy to UAT', ok: 'NOTOK')
      }
    }
  }
}