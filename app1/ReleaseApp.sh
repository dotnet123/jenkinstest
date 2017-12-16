#!/bin/bash
# 获取短版本号
GITHASH=`git rev-parse --short HEAD`
APPNAME='app1'
PUBLISHFOLDER='ReleaseApp'
APPPORT='5007'
CURTime="`date +%Y-%m-%d-%H-%m`"
echo
echo ---------------版本号为...------------------
echo $GITHASH
echo ---------------服务名称...------------------
echo
echo $APPNAME
echo
echo ---------------发布...------------------
echo
dotnet publish $APPNAME  -c Release -o $PUBLISHFOLDER
echo
echo
echo ---------------跳到制定目录------------------
echo
cd  $APPNAME/
echo

echo ---------------移除容器...------------------
echo
docker rm -f $APPNAME || true
echo
echo ---------------Build镜像...------------------
echo
docker build -t $APPNAME:$GITHASH .
echo
echo ---------------镜像打标签...------------------
echo
docker tag $APPNAME:$GITHASH $APPNAME:$CURTime
echo
echo ---------------启动容器...------------------
echo
docker run --name $APPNAME -d -p $APPPORT:5000 --env ASPNETCORE_ENVIRONMENT=Development $APPNAME:$CURTime