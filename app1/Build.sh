#!/bin/bash
APPNAME='app1'
APPPORT='5007'
DOCKERREGISTRY='10.1.4.222:9999'  
APPHOST=('10.1.4.223:2375' '10.1.4.222:2375') 
# 获取GIT短版本号
GITHASH=`git rev-parse --short HEAD`
CURTIME="`date +%Y-%m-%d-%H-%m`"
PUBLISHFOLDER='ReleaseApp'
echo
echo ---------------版本号为...------------------
echo $GITHASH
echo ---------------服务名称...------------------
echo $APPNAME
echo
echo ---------------跳到服务单元测试目录 ------------------
    cd  $APPNAME.test/
echo 
echo ---------------执行单元测试...------------------[当前目录:$(`pwd`)]
echo
   dotnet test
echo 
echo ---------------跳到服务目录 ------------------
    cd  ../$APPNAME/
echo 
echo ---------------开始发布.......------------------ [当前目录:$(`pwd`)]
echo  
   #dotnet publish $APPNAME  -c Release -o $PUBLISHFOLDER
   dotnet publish -c Release -o $PUBLISHFOLDER
echo 


echo ---------------Build镜像...------------------
echo
 docker build -t $APPNAME:$GITHASH .
echo
echo ---------------镜像打标签...------------------
echo
    #docker tag $APPNAME:$GITHASH $APPNAME:$CURTIME
    docker tag $APPNAME:$GITHASH $DOCKERREGISTRY/$APPNAME:$CURTIME  
echo ---------------推送镜像...------------------
echo
     docker push $DOCKERREGISTRY/$APPNAME:$CURTIME  
echo
	for HOST in ${APPHOST[@]}  
	do  
echo ---------------操作主机${HOST}--------------- 
echo
echo
echo ---------------移除容器...------------------
echo
     docker -H tcp://${HOST} rm -f $APPNAME || true
echo
echo ---------------启动容器...------------------
echo
     docker -H tcp://${HOST} run --name $APPNAME -d -p $APPPORT:5000 --env ASPNETCORE_ENVIRONMENT=Development $DOCKERREGISTRY/$APPNAME:$CURTIME
echo
echo
	done  
