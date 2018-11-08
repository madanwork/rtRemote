#!/bin/sh
cd $TRAVIS_BUILD_DIR
rm -rf .git
git clone https://github.com/pxscene/pxCore.git

#build rtCore
cd pxCore
mkdir temp
cd temp
cmake -DBUILD_RTCORE_LIBS=ON -DBUILD_PXCORE_LIBS=OFF -DBUILD_PXSCENE=OFF ..
cmake --build .
retVal=$?
if [ "$retVal" -ne 0 ]
then
        echo "Validation failed because rtCore build failed !!!!!!!!!!!!!!!!!!!!!!!!!";
	exit 1;
fi

#build rtRemote
cd $TRAVIS_BUILD_DIR
pwd
mkdir temp
cd temp
cmake -DCMAKE_CXX_FLAGS=" -I$TRAVIS_BUILD_DIR/pxCore/src/ -L$TRAVIS_BUILD_DIR/pxCore/build/glut/ " -DBUILD_RTREMOTE_SAMPLE_APP_SIMPLE=ON ..
cmake --build . --config Release
retVal=$?
if [ "$retVal" -ne 0 ] 
then
        echo "Validation failed because rtRemote build failed !!!!!!!!!!!!!!!!!!!!!!!!!";
	exit 1;
fi

cd $TRAVIS_BUILD_DIR
#run sample apps
touch clientlogs
count=0
retVal=1
export RT_LOG_LEVEL=debug
export LD_LIBRARY_PATH=$TRAVIS_BUILD_DIR/pxCore/build/glut:$LD_LIBRARY_PATH
./rtSampleServer &
./rtSampleClient > clientlogs 2>&1 &
sleep 30;
grep "value:1234" clientlogs
retVal=$?

kill -15 `ps -ef | grep rtSampleServer|grep -v grep|awk '{print $2}'`
kill -15 `ps -ef | grep rtSampleClient|grep -v grep|awk '{print $2}'`
#perform validation
if [ "$retVal" -eq 1 ]
then
  echo "rtRemote client logs are below:"
  echo "---------------------------------"
  cat clientlogs
  echo "Validation Failed !!!!!!!!!!!!!!!!!!!!!"
  exit 1
fi
echo "Validation Succeeded !!!!!!!!!!!!!!!!!!!!!"
exit 0;
