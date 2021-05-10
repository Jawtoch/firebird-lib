pipeline {
	agent {
		docker {
			image 'swift:latest'
			args '-u root:sudo'
		}
	}
	stages {
		stage('Setup') {
			steps {
				sh 'apt-get update'
				sh 'apt-get install -y firebird-dev'
				sh 'swift package resolve'
			}
		}
		stage('Test') {
			steps {
				sh 'swift test'
			}
		}
	}
}