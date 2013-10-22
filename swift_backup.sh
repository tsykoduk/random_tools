#!/usr/bin/env bash

#####
# You will need to install the swift python client to get this to work
# check out https://community.hpcloud.com/article/python-swiftclient-linux-installation
# for directions
#
# You will want to put this into a directory called backups in the home directory of the user
# who will run this
#####

#####
# Config below
# The name must be unique across all servers using the same swift container.

Swift_Container="Server_Backups"
Server_Unique_Name="Server"
Backups_Home_Directory="/home/ubuntu/backups"

echo $Swift_Container
echo $Server_Unique_Name
echo $Backups_Home_Directory
#
####

# Env Checks

echo "checking for my directories"

if [ ! -d $Backups_Home_Directory ]; then
  echo "woops, something is wrong. My expected home directory is missing. Perhaps a typo in the config?"
  echo "exiting!"
  exit 1
fi

if [ ! -d "${Backups_Home_Directory}/scratch" ]; then
  echo "woops, my scratch directory is missing. I'll create a new one"
  mkdir $Backups_Home_Directory/scratch
fi

if [ ! -d "${Backups_Home_Directory}/backup_storage" ]; then
  echo "woops, my storage directory is missing. I'll create a new one"
  mkdir $Backups_Home_Directory/backup_storage
fi


#start process, create a unique filename
now=`date "+%Y-%m-%d-%H-%M-%S"`
target="${Server_Unique_Name}_${now}.tgz"

echo "starting backup"
echo "moving backup assets over"

#clean up after last run, just incase something went south.
rm -rf ~/backups/scratch/*

# Anything you put into the scratch directory will be backed up, so you can use things like
# MySQL dump or what have you, and just put the resultant files in ~/backups/scratch
#### PUT THE COMMANDS TO COPY THE STUFF YOU WANT TO BACKUP BELOW

cp -R ~/.znc ~/backups/scratch/
cp -R ~/git ~/backups/scratch/
cp -R ~/www ~/backups/scratch/
cp ~/push_site.sh ~/backups/scratch/
cp ~/site_updater ~/backups/scratch/

#### PUT THE COMMANDS TO COPY THE STUFF YOU WANT TO BACKUP ABOVE

#Create the archive
cd ~/backups/
echo "creating archive file named ${target}"
tar -czf $target scratch/*

#Upload to Object Store. You'll want to insure that the container is set correctly

echo "uploading to object storage"
swift upload $Swift_Container $target

#Clean up
echo "Moving archive to storage"
mv $target ~/backups/backup_storage

#clean up the scratch directory
rm -rf ~/backups/scratch/*