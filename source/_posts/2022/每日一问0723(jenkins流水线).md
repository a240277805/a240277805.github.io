---
title:
---
# jenkins 流水线部署

## Jenkins

prod devplatformserver  pipeline script

```
def ProdServer(){
    def remote = [:]
    remote.name = "172.20.60.16"
    remote.host = "172.20.60.16"
    remote.port = 22
    remote.allowAnyHosts = true
    withCredentials([usernamePassword(credentialsId: 'prod-k8s-master1_host-root', passwordVariable: 'password', usernameVariable: 'userName')]) {
        remote.user = "${userName}"
        remote.password = "${password}"
    }
    return remote
}
pipeline {
    agent {
        label 'jenkins-slave'
    }
    environment {
        def DEVOPS_PIPELINE_HOME = "/jenkins_pod_data/devops_server/pipeline_home"
    }
    // parameters { string(name: 'git_branch', defaultValue: '20201113-zmk-k8sdeploy', description: '输入需要发布的分支名称') }
    stages {
        stage('Java Build') {
            steps{
                git branch: "master",
                url: 'https://git.ctfo.com/devops/devplatform-server.git',
                credentialsId: 'dbddbe0b-bfec-4f40-9b9a-a2f5a4bba4fd'
                script{
                    sh '''
                        ### create git-version
                        cd deploy-k8s/jenkins;/bin/bash git-version.sh
                        DOCKER_TAG=`cat git-version`
                        echo $DOCKER_TAG
                        cd ../../

                        mvn clean package
                    '''
                }
            }
        }
        stage('Docker Build image'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'admin-harbor.ctfo.com', passwordVariable: 'harbor_password', usernameVariable: 'harbor_username')]) {
                    sh '''
                    docker login -u $harbor_username -p $harbor_password harbor.ctfo.com
                    DOCKER_TAG=`cat deploy-k8s/jenkins/git-version`
                    echo $DOCKER_TAG
                    docker build -t harbor.ctfo.com/devops/devplatform-server:$DOCKER_TAG .
                    docker push harbor.ctfo.com/devops/devplatform-server:$DOCKER_TAG
                    '''
                }
            }
        }
        stage('Deploy k8s Pod') {
            steps {
                script {
                def sshServer = ProdServer()
                sshPut remote: sshServer, from: "deploy-k8s/jenkins/git-version", into: "/tmp/prod-server.version"
                sshPut remote: sshServer, from: "deploy-k8s/jenkins/prod-deploy-k8s.sh", into: "/tmp/prod-server.sh"
                sshCommand remote: sshServer, command: "bash -x /tmp/prod-server.sh /tmp/prod-server.version"
                ssh '''
                    sleep 90
                '''
                }
            }
        }
    }
}

```

报警 k8s 部署 k8s jenkins-pipeline script

```
def server_d5f217261c364cc1b9c0280f64a90275(){
    def remote = [:]
    remote.name = "172.20.60.95"
    remote.host = "172.20.60.95"
    withCredentials([usernamePassword(credentialsId: 'Mzk2OjIwMjAxMDIyMDgxMTA3MzQ1MjMzMTA4MDE2MDAwMDAxOui3r+WPo+S6keerry3lvIDlj5E=', passwordVariable: 'password', usernameVariable: 'userName')]) {
        remote.user = "$userName"
        remote.password = "$password"
    }
    remote.port = 22
    remote.allowAnyHosts = true
    return remote
}

pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    appName: 7aaf8dcff4f046b695a4204c8a516460
  namespace: jenkins
spec:
  hostAliases:
  - hostnames:
    - harbordev.ctfo.com
    ip: 172.20.80.7
  - hostnames:
    - harbordev-public.ctfo.com
    ip: 172.20.60.31
  containers:
  - name: jnlp
    image: harbor.ctfo.com/jenkins/inbound-agent:4.6-1-alpine-baseimage-10
    imagePullPolicy: IfNotPresent
    env:
    - name: SLAVE_NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    - name: SLAVE_NODE_IP
      valueFrom:
        fieldRef:
          fieldPath: status.hostIP
    securityContext:
      privileged: true
    resources:
      requests:
        memory: "1024Mi"
        cpu: "500m"
    volumeMounts:
    - name: "volume-docker"
      mountPath: "/var/run/docker.sock"
      readOnly: false
    - name: "volume-share"
      subPath: "jenkins_plugin_bin/docker/cli-plugins"
      mountPath: "/usr/libexec/docker/cli-plugins"
      readOnly: false
    - name: "volume-share"
      subPath: "jenkins_plugin_bin/docker/docker"
      mountPath: "/usr/bin/docker"
      readOnly: false
    - name: "volume-share"
      subPath: "jenkins_plugin_bin/mc_bin/mc"
      mountPath: "/usr/bin/mc"
      readOnly: false
    - name: "volume-share"
      subPath: "jenkins_plugin_bin/jenkins_bin/dingtalk"
      mountPath: "/usr/bin/dingtalk"
      readOnly: false
    - name: "volume-share"
      mountPath: "/jenkins_pod_data"
      readOnly: false
  nodeSelector:
    devops-server-type: devops-jenkins-slave
  restartPolicy: "Never"
  tolerations:
  - effect: "NoSchedule"
    key: "prod-devops-tolerations"
    operator: "Exists"
  volumes:
  - name: volume-docker
    hostPath:
      path: /var/run/docker.sock
  - name: volume-share
    persistentVolumeClaim:
      claimName: jenkins-poddata-pvc
      readOnly: false
"""
        }
    }

    stages {
        stage ("start callback"){
            steps {
                container('jnlp') {
                    writeFile (file: '/usr/bin/ccsupgrade.sh', text: '''#!/bin/sh
CCS_CHECK=true
if [ "$CCS_API" == "" ];then
  echo '敏捷云地址未设置!(export CCS_API=http://CCS_IP:30888)'
  CCS_CHECK=false
fi

if [ "$CCS_USERNAME" == "" ];then
  echo '敏捷云账号未设置!(export CCS_USERNAME=admin)'
  CCS_CHECK=false
fi

if [ "$CCS_PASSWORD" == "" ];then
  echo '敏捷云密码未设置!(export CCS_PASSWORD=123456)'
  CCS_CHECK=false
fi

if [ "$CCS_REGISTRY" == "" ];then
  echo '敏捷云仓库地址未设置!(export CCS_REGISTRY=REGISTRY_IP:5000)'
  CCS_CHECK=false
fi

if [ "$CCS_CLUSTER" == "" ];then
  echo '敏捷云集群名称未设置!(export CCS_CLUSTER=main)'
  CCS_CHECK=false
fi

if [ "$CCS_NAMESPACE" == "" ];then
  echo '敏捷云命令空间未设置!(export CCS_NAMESPACE=namespace)'
  CCS_CHECK=false
fi

if [ "$CCS_DEPLOYMENT" == "" ];then
  echo '敏捷云部署名称未设置!(export CCS_DEPLOYMENT=deployname)'
  CCS_CHECK=false
fi

if [ "$CCS_CONTAINER" == "" ];then
  echo '敏捷云容器名称未设置!(export CCS_CONTAINER=containername)'
  CCS_CHECK=false
fi

# login ccs get token
CCS_TOKEN=$(curl -X POST -H 'Cookie: csrfToken=pipeline' -H 'x-csrf-token: pipeline' -H 'Content-Type: application/json' \\
-d '{"username": "'$CCS_USERNAME'", "password": "'$CCS_PASSWORD'"}' \\
"$CCS_API/api/ccs/auth/v1/login" | jq .data | cut -d\\" -f2)

if [ "$CCS_TOKEN" == "" ];then
  echo '敏捷云认证失败! 请检查CCS_USERNAME CCS_PASSWORD变量'
  CCS_CHECK=false
fi

# 检查失败退出
if [ "$CCS_CHECK" == "false" ];then
  exit 1
fi

echo "检查通过!"
echo "开上下载镜像..."
docker pull $IMAGE_TAG
docker save $IMAGE_TAG -o /tmp/image.tar

echo "开始上传镜像..."
curl --proxy 172.17.5.60:32146 -X POST -H "Cookie: csrfToken=pipeline; ccsToken=$CCS_TOKEN" -H 'x-csrf-token: pipeline' -F "file=@/tmp/image.tar" \\
"$CCS_API/api/ccs/apps/v1/imageStores/default/importImageTar"

echo "开始更新镜像..."
# upgrade ccs deployment
curl -XPATCH -H "Cookie: csrfToken=pipeline; ccsToken=$CCS_TOKEN" \\
-H 'x-csrf-token: pipeline' -H "Content-Type: application/strategic-merge-patch+json" \\
-d '{"spec":{"template":{"spec":{"containers":[{"image":"'${IMAGE_TAG/harbor.ctfo.com/$CCS_REGISTRY}'","name":"'$CCS_CONTAINER'"}]}}}}' \\
"$CCS_API/api/ccs/k8s/v1/clusters/$CCS_CLUSTER/namespaces/$CCS_NAMESPACE/deployments/$CCS_DEPLOYMENT"
''')

                    writeFile (file: '/usr/bin/dingtalk.sh', text: '''#!/bin/sh
export DOCKER_HOST=tcp://172.20.3.61:2375;
docker run --rm \\
-e DRONE_BUILD_LINK="$BUILD_URL" \\
-e DRONE_COMMIT_MESSAGE="$GIT_COMMIT_MSG" \\
-e DRONE_COMMIT_AUTHOR="$GIT_COMMITTER_NAME" \\
-e DRONE_COMMIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL" \\
-e DRONE_BUILD_NUMBER="$BUILD_NUMBER" \\
-e DRONE_COMMIT_BRANCH="$GIT_PULL_RESOURCE" \\
-e DRONE_REPO_NAME="$JOB_NAME" \\
-e DRONE_BUILD_STATUS="success" \\
-e DRONE_COMMIT_SHA="$GIT_COMMIT" \\
-e DRONE_COMMIT_LINK="https://git.ctfo.com/znlk/backend/cloud_java/ctfo-cloud-alertevent/-/commit/$GIT_COMMIT" \\
-e DRONE_REMOTE_URL="https://git.ctfo.com/znlk/backend/cloud_java/ctfo-cloud-alertevent.git" \\
-e PLUGIN_TOKEN=$1 \\
-e PLUGIN_SECRET=$2 \\
-e PLUGIN_MSG_TYPE=markdown \\
harbor.ctfo.com/devops-public/drone-dingtalk-message;
unset DOCKER_HOST
''')
                    sh '''
                        echo "jenkins pipeline is Schedule on node $SLAVE_NODE_NAME"
                        curl -X POST "https://devops-api.ctfo.com/ctfo-devplatform-server/api/callback/v1/jenkins/build/start?uniqueKey=$uniqueKey&buildNum=$BUILD_NUMBER"
                        docker buildx create --name mulit-archs --use --driver-opt image=harbor.ctfo.com/devops-public/buildkit:buildx-stable-1,network=host --node mulit-archs

                        mkdir -p /jenkins_pod_data/devops_server/pipeline_home/7aaf8dcff4f046b695a4204c8a516460 /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460
                        echo VERSION_FILE=/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION > /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                        echo BUILD_START=$(date +%s) >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                        echo BUILD_DATE=$(date "+%Y-%m-%d") >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                        echo BUILD_TIME=$(date "+%H:%M:%S") >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                        echo IMAGE_TAG_GIT=$IMAGE_TAG >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                        echo MINIO_PREFIX=$(echo $MINIO_PREFIX | awk -F / '{print $1"/"$2"/'$IMAGE_TAG'/"$4}') >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                        echo SLAVE_NODE_IP=$SLAVE_NODE_IP >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION

                        chmod +x /usr/bin/dingtalk.sh /usr/bin/ccsupgrade.sh /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                    '''
                }
            }
        }
        
        // 镜像构建 镜像构建 pipeline_image_build/pipeline_java_build
        stage('b6644a5e94c04fd79c29659e3847df71') {
            steps {
            
                container('jnlp') {
                    checkout([$class: 'GitSCM', branches: [[name: '$GIT_PULL_RESOURCE']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[
                        credentialsId: 'Mzk2OjIwMjAwOTE2MDkxMTM4MDA4MDIwMDE0MDI1MDAwMDAxOnB5bQ==', url: 'https://git.ctfo.com/znlk/backend/cloud_java/ctfo-cloud-alertevent.git'
                    ]]])

                    withCredentials([usernamePassword(credentialsId: 'Mzk2OjIwMjAwOTE2MDkxMTM4MDA4MDIwMDE0MDI1MDAwMDAxOnB5bQ==', usernameVariable: 'git_username', passwordVariable: 'git_password')]) {
                        sh '''#!/bin/sh
                            GIT_COMMIT=$(git rev-parse --short HEAD)
                            echo GIT_COMMIT=$GIT_COMMIT >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                            #echo GIT_COMMIT_MSG="msg: $(git log -1 --pretty=%B $GIT_COMMIT)" >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                            echo GIT_COMMITTER_NAME=$(git log -1 --pretty=%cn $GIT_COMMIT) >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                            echo GIT_COMMITTER_EMAIL=$(git log -1 --pretty=%ce $GIT_COMMIT) >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION
                            
                            echo docker login -u $git_username -p \\'$git_password\\' harbor.ctfo.com > /tmp/login_harbor
                            sed -i 's#\\$\\$#$#g' /tmp/login_harbor
                            sh /tmp/login_harbor || true

                            GIT_PASSWORD=$(echo $git_password | tr -d '\n' | od -An -tx1| tr ' ' %)
                            echo 'git config --global url."https://'$git_username':'$GIT_PASSWORD'@git.ctfo.com".insteadOf "https://git.ctfo.com"' > .git_init.sh
                            sh .git_init.sh

                            #rm -rf .dockerignore
                            echo *.dockerfile > .dockerignore
                        '''
                    }

                    
                    script {
                        readProperties(text: readFile(file: '/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION')).each {
                            env."${it.key}" = "${it.value}"
                        }
                    }
                }

                container('jnlp'){
                    writeFile (file: 'compile-shell-b6644a5e94c04fd79c29659e3847df71.sh', text: '''#!/bin/sh
# 加载全局的环境变量, 以便在脚本中直接使用
IFS_O=$IFS; IFS=$'\n\n'; for line in $(cat compile-env-b6644a5e94c04fd79c29659e3847df71.sh); do export $line;done; IFS=$IFS_O

# 执行不同语言的预处理脚本
/usr/local/bin/mvn-entrypoint.sh || true

# 开启执行跟踪
set -xe

# 执行用户的编译脚本, 里面可以直接使用全局的环境变量
mvn clean package -DskipTests
''')
                    writeFile (file: 'compile-docker-b6644a5e94c04fd79c29659e3847df71.dockerfile', text: '''FROM --platform=$BUILDPLATFORM harbor.ctfo.com/jenkins/maven:3.8.2-jdk-8-buildjava-12 as pipeline-builder
ARG BUILDPLATFORM
ARG BUILDOS
ARG BUILDARCH
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
WORKDIR /root
COPY . .
RUN sh compile-shell-b6644a5e94c04fd79c29659e3847df71.sh
FROM scratch
ARG BUILDPLATFORM
ARG BUILDOS
ARG BUILDARCH
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
''')

                    writeFile (file: 'ctfo_prepare-b6644a5e94c04fd79c29659e3847df71.sh', text: '''''')

                    sh '''#!/bin/sh
                        set -xe
                        # 编译制品
                        mkdir -p /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71
                        cp /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/CTFO_VERSION /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION
                        echo "ARTIFACTS_PATH=/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71" >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION
                        echo "WORKDIR=/app" >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION
                        
                        

                        cp /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION compile-env-b6644a5e94c04fd79c29659e3847df71.sh

                        chmod +x compile-shell-b6644a5e94c04fd79c29659e3847df71.sh

                        echo '#!/bin/sh -e
exec java \\
    $JAVA_OPTS \\
    -Djava.security.egd=file:/dev/./urandom \\
    -Dfile.encoding=UTF-8 \\
    -Dsun.jnu.encoding=UTF-8 \\
    -jar /app//alerevent-0.0.1-SNAPSHOT.jar \\
    $*
    ' > ctfo_entrypoint-b6644a5e94c04fd79c29659e3847df71.sh
                        chmod +x ctfo_entrypoint-b6644a5e94c04fd79c29659e3847df71.sh

                    '''
                }


                                
                container('jnlp') {
                    script {
                        readProperties(text: readFile(file: '/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION')).each {
                            env."${it.key}" = "${it.value}"
                        }
                    }

                    sh '''
                        echo 'COPY --from=pipeline-builder /root/target/alerevent-0.0.1-SNAPSHOT.jar //app/' >> compile-docker-b6644a5e94c04fd79c29659e3847df71.dockerfile
                      
                        echo "$RUNCOPY" | sed 's#^\\s*COPY\\s*#COPY --from=pipeline-builder /root/#g' >> compile-docker-b6644a5e94c04fd79c29659e3847df71.dockerfile
                      
                        # 无架构编译
                        if [ -f compile-shell-b6644a5e94c04fd79c29659e3847df71.sh ];then
                            docker buildx build -f compile-docker-b6644a5e94c04fd79c29659e3847df71.dockerfile -o type=local,dest=/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/linux_amd64 .
                        fi
                        cd $WORKSPACE
                        
                        export TARGETPLATFORM=linux/amd64
                        export TARGETOS=linux
                        export TARGETARCH=amd64
                        if [ ! -f compile-shell-b6644a5e94c04fd79c29659e3847df71.sh ];then
                            mkdir -p /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/linux_amd64
                            cp -r target/alerevent-0.0.1-SNAPSHOT.jar /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/linux_amd64//app/
                        fi

                        BUCKET_NAME=znlk-cloud
                        BIN_FILE_NAME=/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/ctfo-cloud-alertevent.tar.gz
                        MINIO_PATH=$BUCKET_NAME/ctfo-cloud-alertevent/$MINIO_PREFIX

                        # 先进入制品目录
                        cd /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/linux_amd64

                        FILE_NUM=$(find -type f| wc -l)
                        if [[ $FILE_NUM -eq 1 ]];then
                            PUSH_FILE_NAME=/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/linux_amd64/$(find -type f)
                        else
                            tar -czf $BIN_FILE_NAME *
                            PUSH_FILE_NAME=$BIN_FILE_NAME
                        fi
                        echo "BIN_FILE_NAME_amd64=$PUSH_FILE_NAME" >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION
                        echo "BIN_FILE_NUM_amd64=$FILE_NUM" >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION

                        # 制作待推送文件的  md5 文件
                        FILE_NAME_MD5=$(md5sum $PUSH_FILE_NAME | awk '{print $1}')
                        FILE_NAME=$(basename $PUSH_FILE_NAME)
                        echo $FILE_NAME_MD5 $FILE_NAME> $PUSH_FILE_NAME.md5

                        # 创建bucket, 分配下载权限
                        mc mb http_prod-minio-devops/$BUCKET_NAME || true
                        mc policy set download http_prod-minio-devops/$BUCKET_NAME || true
                        mc cp $PUSH_FILE_NAME http_prod-minio-devops/$MINIO_PATH/$FILE_NAME
                        mc cp $PUSH_FILE_NAME.md5 http_prod-minio-devops/$MINIO_PATH/$FILE_NAME_MD5.md5
                        echo "{
                            \\"stageId\\":\\"b6644a5e94c04fd79c29659e3847df71\\",
                            \\"pushMinioResult\\":\\"$(mc ls http_prod-minio-devops/$MINIO_PATH/$FILE_NAME)\\",
                            \\"minioPath\\":\\"$MINIO_PATH/$FILE_NAME\\",
                            \\"bucketName\\":\\"$BUCKET_NAME\\",
                            \\"fileName\\":\\"$FILE_NAME\\"
                        }" > /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71_buildparam.txt
                    '''
                }

                                container('jnlp') {
                    withCredentials([usernamePassword(credentialsId: 'Mzk2OjIwMjAwOTE2MDkxMTM4MDA4MDIwMDE0MDI1MDAwMDAxOnB5bQ==', usernameVariable: 'harbor_username', passwordVariable: 'harbor_password')]) {
                        sh '''
                            echo docker login -u $harbor_username -p \\'$harbor_password\\' harbor.ctfo.com > /tmp/login_harbor
                            sed -i 's#\\$\\$#$#g' /tmp/login_harbor
                            sh /tmp/login_harbor
                            export BASE_IMAGE_DIGEST=$(curl -k 'https://$harbor_username:$harbor_password@harbor.ctfo.com/api/v2.0/projects/jenkins/repositories/openjdk/artifacts' | jq '[foreach .[] as $item ([]; $item; if $item.tags == null then empty else $item end)] | [foreach .[] as $item ([]; $item; if $item.tags[].name == "8-runjava-10" then $item.digest else empty end)] | first' | xargs)
                            if [ "$BASE_IMAGE_DIGEST" != "" ] ; then
                              echo "BASE_IMAGE_DIGEST=$BASE_IMAGE_DIGEST" >>  /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION
                            fi
                        '''
                    }

                    script {
                        readProperties(text: readFile(file: '/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION')).each {
                            env."${it.key}" = "${it.value}"
                        }
                        env.IMAGE_TAG = "harbor.ctfo.com/test-public/ctfo-cloud-alertevent:" + env.IMAGE_TAG
                    }


                    sh '''#!/bin/sh
                        # 设置环境变量
                        echo IMAGE_TAG=$IMAGE_TAG >> /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION
                        set -xe

                        sed -i '/COPY --from=/d' compile-docker-b6644a5e94c04fd79c29659e3847df71.dockerfile
                        if [ -f ./Dockerfile ]; then
                          cat ./Dockerfile | sed '/--from=/!s#^\\s*COPY\\s*#COPY --from=pipeline-builder /root/#g' | sed '/--from=/!s#^\\s*ADD\\s*#COPY --from=pipeline-builder /root/#g' >> compile-docker-b6644a5e94c04fd79c29659e3847df71.dockerfile
                        elif [ -f ./Dockerfile/Dockerfile ]; then
                          cat ./Dockerfile/Dockerfile | sed '/--from=/!s#^\\s*COPY\\s*#COPY --from=pipeline-builder /root/#g' | sed '/--from=/!s#^\\s*ADD\\s*#COPY --from=pipeline-builder /root/#g' >> compile-docker-b6644a5e94c04fd79c29659e3847df71.dockerfile
                        else
                          echo "./Dockerfile not exist Dockerfile!"
                          exit 1
                        fi
                        
                        docker buildx build --platform linux/amd64 -t $IMAGE_TAG -f compile-docker-b6644a5e94c04fd79c29659e3847df71.dockerfile --push .
                    '''
                }
            }
        }

        // 部署 K8S发布 pipeline_deploy/deploy_k8s_upgrade
        stage('d5f217261c364cc1b9c0280f64a90275') {
            steps {
            
                container('jnlp') {
                    sh '''
                        mkdir -p /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/d5f217261c364cc1b9c0280f64a90275
                        cp /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/b6644a5e94c04fd79c29659e3847df71/CTFO_VERSION /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/d5f217261c364cc1b9c0280f64a90275
                    '''

                    script {
                        readProperties(text: readFile(file: '/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/d5f217261c364cc1b9c0280f64a90275/CTFO_VERSION')).each {
                            env."${it.key}" = "${it.value}"
                        }
                    }


                    writeFile (file: '/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/d5f217261c364cc1b9c0280f64a90275/deploy_k8s_upgrade_d5f217261c364cc1b9c0280f64a90275.sh', text: '''#!/bin/sh
if [ -f CTFO_VERSION ] ; then IFS_O=$IFS; IFS=$'\n\n'; for line in $(cat CTFO_VERSION); do export $line;done; IFS=$IFS_O; fi

set -xe

set -xe
export IS_RESTART=$(kubectl set image Deployment ctfo-cloud-alertevent -n znlk-cloud ctfo-cloud-alertevent=$IMAGE_TAG)
if [ "$IS_RESTART" == "" ];then
    kubectl rollout restart -n znlk-cloud Deployment ctfo-cloud-alertevent
fi
                        
''')

                    sh '''
                        cd /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/d5f217261c364cc1b9c0280f64a90275
                        chmod +x /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/d5f217261c364cc1b9c0280f64a90275/deploy_k8s_upgrade_d5f217261c364cc1b9c0280f64a90275.sh
                        tar -czf deployment.tgz *
                    '''
                    
                    script {
                        def remote = server_d5f217261c364cc1b9c0280f64a90275()
                        sshCommand remote: remote, command: "mkdir -p /tmp/d5f217261c364cc1b9c0280f64a90275"
                        sshPut remote: remote, from: "/home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/d5f217261c364cc1b9c0280f64a90275/deployment.tgz", into: "/tmp/d5f217261c364cc1b9c0280f64a90275"
                        sshCommand remote: remote, command: '''
                            cd /tmp/d5f217261c364cc1b9c0280f64a90275; tar -xzf deployment.tgz; rm -f deployment.tgz
                            nohup bash -x deploy_k8s_upgrade_d5f217261c364cc1b9c0280f64a90275.sh > service.log 2>&1 &
                        '''
                    }

                    sh '''
                        rm -rf /home/jenkins/agent/7aaf8dcff4f046b695a4204c8a516460/d5f217261c364cc1b9c0280f64a90275
                    '''
                }
            }
        }

    }

    post {
        always {
            script {
                execCode = sh(script: '''
                  curl -X POST "https://devops-api.ctfo.com/ctfo-devplatform-server/api/callback/v1/jenkins/build/finished?uniqueKey=$uniqueKey&buildNum=$BUILD_NUMBER"
                ''', returnStatus: true)
                echo "$execCode"
            }
        }
    }
}
        
```

