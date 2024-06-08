#! /bin/bash

function resume() {
    sudo mv $BackupDir/"$LastPackageName".backup/* $RUN_DIR
    if [ $? -ne 0 ]; then
       echo "Failed to resume service." >> $LOG_FILE
       exit -1
    fi
}

if [ $# -ne 2 ]; then
    echo "Usage: ./update.sh <package-path>"
    exit -1
fi

PackagePath=$1
NewVersion=$2

UncompressDir=v"$NewVersion"

ServiceName=AethirCheckerService
CLIName=AethirCheckerCLI

BackupDir=/opt/tmp/Aethir
sudo mkdir -p $BackupDir/$UncompressDir

RUN_DIR=$(dirname $(realpath $0))

LastPackageName=$(basename "$RUN_DIR")

NewPackageName=$(basename "$PackagePath")

LOG_FILE=$RUN_DIR/update.log

# backup
sudo cp -Rd $RUN_DIR $BackupDir/"$LastPackageName".backup

sudo tar -xvf $PackagePath -C $BackupDir/$UncompressDir --strip-components 1
if [ $? -ne 0 ]; then
    echo "Failed uncompress installation package." >> $LOG_FILE
    exit -1
fi

sudo rm -rf $RUN_DIR/config
#sudo rm -rf $RUN_DIR/log
sudo mv $BackupDir/$UncompressDir/* $RUN_DIR
if [ $? -ne 0 ]; then
    echo "Failed to update service. to resume" >> $LOG_FILE
    resume
    exit -1
fi

sudo rm -rf $BackupDir
sudo rm -rf $PackagePath

#sudo ps -ef | grep $CLIName | grep -v grep | awk '{print $2}' | xargs kill -9

sudo systemctl restart aethir-checker
if [ $? -ne 0 ]; then
    echo "Failed to restart service. " >> $LOG_FILE
    exit -1
fi

exit 0
