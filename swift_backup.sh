#!/usr/bin/env bash

#####
# You will need to install the swift python client to get this to work
# check out https://community.hpcloud.com/article/python-swiftclient-linux-installation
# for directions
#
#####

#####
# Config below

# The name of the Object storage container you are targeting
Swift_Container="Server_Backups"

# The name must be unique across all servers using the same swift container.
Server_Unique_Name="Server"

# The full path to the working directory.
Backups_Home_Directory="/home/ubuntu/backups"

#What directory do you want logs dumped into
Logs_Directory="/home/ubuntu/backups/logs"


#start up

# first off, we need to check for the logs directory

if [ ! -d "${Logs_Directory}" ]; then
  echo "woops, my logs directory is missing. I'll create a new one"
  mkdir $Logs_Directory
fi

now=`date "+%Y-%m-%d-%H-%M-%S"`
logs="${Logs_Directory}/${now}.txt"
touch $logs
echo "starting up at ${now}">>$logs
echo "Swift Container = ${Swift_Container}">>$logs
echo "Server's Unique Name = ${Server_Unique_Name}">>$logs
echo "Backup Home Directory = ${Backups_Home_Directory}">>$logs
echo "Logging Directory = ${Logs_Directory}">>$logs
#
####

# Env Checks

echo "checking for my directories">>$logs

if [ ! -d $Backups_Home_Directory ]; then
  echo "woops, something is wrong. My expected home directory is missing. Perhaps a typo in the config?">>$logs
  echo "exiting!">>$logs
  exit 1
fi

if [ ! -d "${Backups_Home_Directory}/scratch" ]; then
  echo "woops, my scratch directory is missing. I'll create a new one">>$logs
  mkdir $Backups_Home_Directory/scratch
fi

if [ ! -d "${Backups_Home_Directory}/backup_storage" ]; then
  echo "woops, my storage directory is missing. I'll create a new one">>$logs
  mkdir $Backups_Home_Directory/backup_storage
fi


#start process, create a unique filename
target="${Server_Unique_Name}_${now}.tgz"

echo "starting backup">>$logs
echo "moving backup assets over">>$logs

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
echo "creating archive file named ${target}">>$logs
tar -czf $target scratch/*

#Upload to Object Store. You'll want to insure that the container is set correctly

echo "uploading to object storage">>$logs
swift upload $Swift_Container $target >>$logs

#Clean up
echo "Moving archive to storage">>$logs
mv $target ~/backups/backup_storage

#clean up the scratch directory
echo "cleaning up">>$logs
rm -rf ~/backups/scratch/*

finish=`date "+%Y-%m-%d-%H-%M-%S"`
echo "backup completed at ${finish}">>$logs