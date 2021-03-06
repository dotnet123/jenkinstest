﻿#!/bin/bash
# 获取短版本号
GITHASH=`git rev-parse --short HEAD`
APPNAME='app2'
PUBLISHFOLDER='ReleaseApp'
APPPORT='5008'
CURTime="`date +%Y%m%d-%H-%m`"
echo
echo ---------------版本号为...------------------
echo $GITHASH
echo ---------------服务名称...------------------
echo $APPNAME
echo ---------------开始发布...------------------

dotnet publish $APPNAME  -c Release -o $PUBLISHFOLDER
echo
echo---------------发布完成...------------------

echo ---------------跳到制定目录------------------
echo  $APPNAME/
cd  $APPNAME/
echo

echo ---------------Build镜像...------------------
echo
docker build -t $APPNAME:$GITHASH .
echo
echo ---------------镜像打标签...------------------
echo
#docker tag $APPNAME:$GITHASH $APPNAME:latest
#docker tag $APPNAME:$GITHASH $APPNAME:$CURTime
docker tag $APPNAME:$GITHASH 10.1.4.222:9999/$APPNAME:$CURTime  
echo
echo ---------------推送镜像...------------------
echo
docker push 10.1.4.222:9999/$APPNAME:$CURTime  
echo
echo ---------------移除容器...------------------
echo
docker rm -f $APPNAME || true
echo
echo ---------------启动容器...------------------
echo
docker run --name $APPNAME -d -p $APPPORT:5000 --env ASPNETCORE_ENVIRONMENT=Development $APPNAME:$CURTime