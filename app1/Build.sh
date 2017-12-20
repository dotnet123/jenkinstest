#!/bin/bash
DockerAppName='app1'
DockerPORT='5007'
DOCKERREGISTRY='10.1.4.222:9999'  
#APPHOST=('10.1.4.223:2375' '10.1.4.222:2375') 
APPHOST=('10.1.4.222:2375') 
# 获取GIT短版本号
GITHASH=`git rev-parse --short HEAD`
CURTIME="`date +%Y-%m-%d-%H-%m`"
PUBLISHFOLDER='ReleaseApp'
AppPath="$WORKSPACE/$JOB_NAME/" 
# testPath="$WORKSPACE/$JOB_NAME.test/"  
# testLog="$WORKSPACE/$JOB_NAME.test/test-$GITHASH.log"  
# if [ ! -d "$testPath" ];then  
# echo "没找到单元测试项目"
# exit 1
# fi
#echo---------------检测测试结果...------------------ 
#if [ ! -f "$testLog" ];then
#echo "没找到单元测试报告文件" 
#exit 1
#fi
#lastLineLog=`tail -1 $testLog`
#SUFFIX="code of 1"
#if [[ lastLineLog == *$SUFFIX ]];then
#echo "单元测试未通过"
#exit 1
#fi
echo ---------------跳到服务目录 ------------------
cd  $AppPath
echo 
echo ---------------开始发布.......------------------ 
echo  
   #dotnet publish $APPNAME  -c Release -o $PUBLISHFOLDER
   dotnet publish -c Release -o $PUBLISHFOLDER
echo 
echo ---------------Build镜像...------------------
echo
   docker build -t $DockerAppName:$GITHASH .
echo
echo ---------------镜像打标签...------------------
echo
    #docker tag $APPNAME:$GITHASH $APPNAME:$CURTIME
    docker tag $DockerAppName:$GITHASH $DOCKERREGISTRY/$DockerAppName:$CURTIME  
echo ---------------推送镜像...------------------
echo
     docker push $DOCKERREGISTRY/$DockerAppName:$CURTIME  
echo
	for HOST in ${APPHOST[@]}  
	do  
echo ---------------操作主机${HOST}--------------- 
echo
echo
echo ---------------移除容器...------------------
echo
     docker -H tcp://${HOST} rm -f $DockerAppName || true
echo
echo ---------------启动容器...------------------
echo
     docker -H tcp://${HOST} run --name $DockerAppName -d -p $DockerPORT:5000 --env ASPNETCORE_ENVIRONMENT=Development $DOCKERREGISTRY/$DockerAppName:$CURTIME
echo
echo
	done  
