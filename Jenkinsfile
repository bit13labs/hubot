#!groovy
import com.bit13.jenkins.*

if(env.BRANCH_NAME ==~ /master$/) {
		return
}


node ("node") {
	def ProjectName = "hubot"
	def slack_notify_channel = null

	def MAJOR_VERSION = 2
	def MINOR_VERSION = 19


	properties ([
		buildDiscarder(logRotator(numToKeepStr: '25', artifactNumToKeepStr: '25')),
		disableConcurrentBuilds(),
		pipelineTriggers([
			pollSCM('H/30 * * * *')
		]),
	])

	env.PROJECT_MAJOR_VERSION = MAJOR_VERSION
	env.PROJECT_MINOR_VERSION = MINOR_VERSION

	env.CI_BUILD_VERSION = Branch.getSemanticVersion(this)
	env.CI_DOCKER_ORGANIZATION = "bit13"
	env.CI_PROJECT_NAME = ProjectName
	currentBuild.result = "SUCCESS"

	def errorMessage = null
	wrap([$class: 'TimestamperBuildWrapper']) {
		wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
			Notify.slack(this, "STARTED", null, slack_notify_channel)
			try {
					stage ("install" ) {
						deleteDir()
						//env.CODECOV_TOKEN = SecretsVault.get(this, "secret/${env.CI_PROJECT_NAME}", "CODECOV_TOKEN")
						Branch.checkout(this, env.CI_PROJECT_NAME, "bit13labs")
						Pipeline.install(this)
						sh script: "npm version '${env.CI_BUILD_VERSION}' --no-git-tag-version"
						Node.createAuthenticationFile(this, env.CI_DOCKER_ORGANIZATION)
						sh script: 'npm install'
					}
					stage ("lint") {
						sh script: "${WORKSPACE}/.deploy/lint.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
					}
					stage ("build") {
						sh script: "${WORKSPACE}/.deploy/build.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
					}
					stage ("test") {
						// sh script: "${WORKSPACE}/.deploy/test.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
					}
					stage ("package") {
						sh script: "${WORKSPACE}/.deploy/package.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
					}
					stage ('publish') {
					  sh script:  "${WORKSPACE}/.deploy/publish.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
						Branch.publish_to_master(this)
						Pipeline.publish_buildInfo(this)
					}
			} catch(err) {
				currentBuild.result = "FAILURE"
				errorMessage = err.message
				throw err
			}
			finally {
				Pipeline.finish(this, currentBuild.result, errorMessage)
			}
		}
	}
}
