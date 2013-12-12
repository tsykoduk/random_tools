#!/bin/sh
#

unset GIT_DIR

echo "Starting to push to production"
cd /home/ubuntu/www

echo "Get updates"
git pull -v
cd output

echo "generate a new gitlister.html file"
files=`find *.gif`
rm ./giflister.html
touch ./giflister.html
output=./giflister.html
for f in $files; do ( 
    echo "<li><a href='./$f'>$f</a></li>" >> $output
)
done

echo "push to prod"
sudo cp -R * /srv/www
cd /srv/www
sudo chown -R www-data:www-data *
echo "done!"