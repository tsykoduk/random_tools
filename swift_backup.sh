#!/usr/bin/env bash

#####
# You will need to install the swift python client to get this to work
# check out https://community.hpcloud.com/article/python-swiftclient-linux-installation 
# for directions


#start process, create a unique filename
now=`date "+%Y-%m-%d-%H-%M-%S"`
target="backups_${now}.tgz"

echo "starting backup"
echo "moving backup assets over"

#clean up after last run
rm -rf ~/backups/scratch/*

#Anything you put into the scratch directory will be backed up, so you can use things like
#MySQL dump or what have you, and just put the resultant files in ~/backups/scratch

cp -R ~/.znc ~/backups/scratch/
cp -R ~/git ~/backups/scratch/
cp -R ~/www ~/backups/scratch/
cp ~/push_site.sh ~/backups/scratch/
cp ~/site_updater ~/backups/scratch/



#Create the archive
cd ~/backups/
echo "creating archive file named ${target}"
tar -czf $target scratch/*

#Upload to Object Store. You'll want to insure that the container is set correctly

Swift_Container="Server_Backups"

echo "uploading to object storage" 
swift upload $Swift_Container $target

#Clean up
echo "Moving archive to storage"
mv $target ~/backups/backup_storage