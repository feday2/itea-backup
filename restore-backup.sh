#!/bin/bash

########################################## Set variables ###############################################################################

backupDir="backups"
restoreDir="backend/web/uploads"

######################################### Start script #################################################################################

set -e

srcDir="$( cd "$(dirname "$0")" ; pwd -P )"
backupPath=$srcDir/$backupDir
restorePath=$srcDir/$restoreDir
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ ! $1 ]] 
    then
    echo -e "${RED}Missing date of backup${NC}"
    exit 1
fi

if [[ $2 ]] 
    then
    echo "Too many arguments, take first \"$1\""
fi

if [[ ! $1 =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]]
  then 
  echo -e "${RED}Wrong date format, use DD-MM-YYYY${NC}"
  exit 1
fi

if [[ ! -d "$backupPath" ]] 
    then
    echo "Backup dir ($backupPath) not exist"
    exit 1
fi

if [[ ! -d "$backupPath/$1" ]] 
    then
    echo -e "${RED}Backup for date $1 not exist${NC}"
    echo "Available backups:" 
    ls $backupPath/ | grep -E "^[0-9]{2}-[0-9]{2}-[0-9]{4}$"
    exit 1
fi

if [[ ! -f "$backupPath/$1/uploads.zip" ]] 
    then
    echo -e "${RED}Backup for date $1 exist but backup files are missing${NC}"
    exit 1
elif [[ ! -f "$backupPath/$1/dump.sql.gz" ]]
    then
    echo -e "${RED}Backup for date $1 exist but backup MySQL are missing${NC}"
    exit 1
fi

if [[ ! -d "$restorePath" ]]
    then
    echo "destination dir ($restorePath) is missing, will create"
    mkdir -p $restorePath
fi

rm -rf $restorePath/*
echo -e "${GREEN}-----copy backup files-----${NC}"
unzip $backupPath/$1/uploads.zip -d $restorePath/ > /dev/null 2>&1
echo -e "${GREEN}-----copy restore MySQL dump-----${NC}restore DB, smth like this:"
echo "user@localhost# mysql -u DBuser -p DBname | someplace/delAllTables.sql"
echo "user@localhost# zcat $backupPath/$1/dump.sql.gz | mysql -u DBuser -p DBname"
gzip -dc < $backupPath/$1/dump.sql.gz > $srcDir/dump.sql


