#!/bin/sh
#

# This will pull down, run, and automatically deploy a nanoc directory
# Also it will scan the output directory and create a list of all of the .gif, .jpg and .png file
# Great for having those "memes" close at hand when you need them
# It's best to be run as a git post-recive hook on a server that you push to

# It will output it's progress to the remote git, so you get cool heroku-esq push messages.


# Set these to something sane for your enviroment

$STAGING="~/nanoc"
$PRODUCTION="/srv/www"
$WWW-USER="www-data"
$WWW-GROUP="www-data"


#the rest works for me...
unset GIT_DIR

echo "Starting to push to production"
cd ~/$STAGING

echo "Get updates"
git pull -v
cd output

echo "generate a new gitlister.html file"
files=`find .  -name "*.gif" -o -name "*.jpg" -o -name "*.png"`
rm ./giflister.html
touch ./giflister.html
output=./giflister.html
for f in $files; do ( 
    echo "<li><a href='./$f'>$f</a></li>" >> $output
)
done

echo "sort the file"
sort giflister.html -o giflister.html

echo "copy stuff over, and set the permissions correctly"

cp -R * $PRODUCTION

cd $PRODUCTION

#Might need sudo here, or not. In fact, depending on your set up, might not even need this at all!

chown -R $WWW-USER:$WWW-GROUP *

echo "done!"