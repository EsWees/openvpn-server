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