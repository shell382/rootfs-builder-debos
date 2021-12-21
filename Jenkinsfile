String cron_string = BRANCH_NAME == 'master' ? 'H 3 * * *' : ''

def build_image = {
  sh '''
    ./debos-podman \
      "./$RECIPE" \
      --fakemachine-backend kvm \
      -m 2G \
      --scratchsize 10G \
      --cpus $(nproc --all) \
      -e "http_proxy:http://$(ip route get 8.8.8.8 | head -1 | cut -d\' \' -f7):3142" \
      -t "image:$IMAGE" -t "architecture:${ARCHITECTURE}"
  '''
  sh 'echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)_${ARCHITECTURE}_${GIT_BRANCH}_${BUILD_NUMBER}_${GIT_COMMIT}" | tee "${IMAGE}.build"'
  archiveArtifacts(artifacts: '*.tar.gz,*.build,*.manifest', fingerprint: true, onlyIfSuccessful: true)
}

def check_for_changes = {
  sh 'git branch --force master $(git show-ref -s origin/master)'
  return sh (
    returnStatus: true,
    script: '! git diff --quiet $GIT_COMMIT origin/master -- focal/ scripts/ common/ Jenkinsfile'
  )
}

pipeline {
  agent none
  triggers {
    cron(cron_string)
  }
  options {
    buildDiscarder(logRotator(artifactNumToKeepStr: '30', numToKeepStr: '180'))
  }
  stages {
    stage('Rootfs builds') {
      parallel {
        stage('focal-hybris-arm64') {
          agent { label 'debos-amd64' }
          when {
            beforeAgent false
            anyOf {
              branch 'master'
              expression { check_for_changes() == 0 }
            }
          }
          environment {
            RECIPE = 'focal/ubuntu-touch-hybris-rootfs.yaml'
            IMAGE = 'ubuntu-touch-hybris-rootfs-arm64.tar.gz'
            ARCHITECTURE = 'arm64'
          }
          steps {
            script {build_image()}
          }
          post {
            cleanup {
              deleteDir()
            }
          }
        }
        stage('focal-hybris-armhf') {
          agent { label 'debos-amd64' }
          when {
            beforeAgent false
            anyOf {
              branch 'master'
              expression { check_for_changes() == 0 }
            }
          }
          environment {
            RECIPE = 'focal/ubuntu-touch-hybris-rootfs.yaml'
            IMAGE = 'ubuntu-touch-hybris-rootfs-armhf.tar.gz'
            ARCHITECTURE = 'armhf'
          }
          steps {
            script {build_image()}
          }
          post {
            cleanup {
              deleteDir()
            }
          }
        }
      }
    }
  }
}
