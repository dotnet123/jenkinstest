#!/bin/bash
APPNAME='app1'
APPPORT='5007'
DOCKERREGISTRY='10.1.4.222:9999'  
#APPHOST=('10.1.4.223:2375' '10.1.4.222:2375') 
APPHOST=('10.1.4.222:2375') 
# ��ȡGIT�̰汾��
GITHASH=`git rev-parse --short HEAD`
CURTIME="`date +%Y-%m-%d-%H-%m`"
PUBLISHFOLDER='ReleaseApp'
appPath="$WORKSPACE/$JOB_NAME/" 
# testPath="$WORKSPACE/$JOB_NAME.test/"  
# testLog="$WORKSPACE/$JOB_NAME.test/test-$GITHASH.log"  
# if [ ! -d "$testPath" ];then  
# echo "û�ҵ���Ԫ������Ŀ"
# exit 1
# fi
#echo---------------�����Խ��...------------------ 
#if [ ! -f "$testLog" ];then
#echo "û�ҵ���Ԫ���Ա����ļ�"
#exit 1
#fi
#lastLineLog=`tail -1 $testLog`
#SUFFIX="code of 1"
#if [[ lastLineLog == *$SUFFIX ]];then
#echo "��Ԫ����δͨ��"
#exit 1
#fi
echo ---------------��������Ŀ¼ ------------------
cd  $appPath
echo 
echo ---------------��ʼ����.......------------------ 
echo $(`pwd`)
echo  
   #dotnet publish $APPNAME  -c Release -o $PUBLISHFOLDER
   dotnet publish -c Release -o $PUBLISHFOLDER
echo 
echo ---------------Build����...------------------
echo
 docker build -t $APPNAME:$GITHASH .
echo
echo ---------------������ǩ...------------------
echo
    #docker tag $APPNAME:$GITHASH $APPNAME:$CURTIME
    docker tag $APPNAME:$GITHASH $DOCKERREGISTRY/$APPNAME:$CURTIME  
echo ---------------���;���...------------------
echo
     docker push $DOCKERREGISTRY/$APPNAME:$CURTIME  
echo
	for HOST in ${APPHOST[@]}  
	do  
echo ---------------��������${HOST}--------------- 
echo
echo
echo ---------------�Ƴ�����...------------------
echo
     docker -H tcp://${HOST} rm -f $APPNAME || true
echo
echo ---------------��������...------------------
echo
     docker -H tcp://${HOST} run --name $APPNAME -d -p $APPPORT:5000 --env ASPNETCORE_ENVIRONMENT=Development $DOCKERREGISTRY/$APPNAME:$CURTIME
echo
echo
	done  
