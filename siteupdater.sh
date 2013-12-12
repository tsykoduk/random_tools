#!/bin/sh
#

unset GIT_DIR

echo "Starting to push to production"
cd /home/ubuntu/www

# Get updates
git pull -v
cd output

#generate a new gitlister.html file
files=`find .  -name "*.gif" -o -name "*.jpg" -o -name "*.png"`
rm ./giflister.html
touch ./giflister.html
output=./giflister.html
for f in $files; do ( 
    echo "<li><a href='./$f'>$f</a></li>" >> $output
)
done

#copy stuff over, and set the permissions correctly

sudo cp -R * /srv/www
cd /srv/www
sudo chown -R www-data:www-data *
echo "done!"