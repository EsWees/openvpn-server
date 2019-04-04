pipeline {
  agent any
  stages {
    stage('pStep1') {
      steps {
        echo 'Start pipeline'
        sleep 5
      }
    }
    stage('Build step') {
      steps {
        sleep 5
      }
    }
    stage('Start app') {
      steps {
        sleep 2
      }
    }
    stage('Deploy app confirmation') {
      steps {
        input(message: 'Approve', ok: 'Yes. Deploy this into production')
      }
    }
  }
}