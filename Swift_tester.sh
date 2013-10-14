#!/bin/bash
# Collin's Dirty Sed Auth and an example swift call
# Slightly modified by @tsykoduk

#
# Tests the Swift API from your location
# It will run swift API commands via Curl to US-West and US-East
# You'll need to set up a target container in US-West and US-East
# 
# Change the config below to suit your enviroment

export test_file=/CHANGE/ME/TO/SOME_FILE
export container="CHANGE ME"
export HP_PROJECT_ID="CHANGE ME"
export HP_ACCESS_KEY="CHANGE ME"
export HP_SECRET_KEY="CHANGE ME"

#
###

export test_file_name=$(basename $test_file)
export HPAuth=$(curl -s -X POST -H "Content-Type: application/json" https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/tokens -d '{"auth:{"apiAccessKeyCredentials":{"accessKey":"'$HP_ACCESS_KEY'", "secretKey":"'$HP_SECRET_KEY'"}, "tenantId":"'$HP_PROJECT_ID'"}}' | grep "HPAuth" | sed 's/^    \"id\": \"//' | sed 's/\",//') 
curl -i -H "x-auth-token: $HPAuth" https://region-a.geo-1.objects.hpcloudsvc.com/v1/$HP_PROJECT_ID/$container/$test_file_name -X PUT -T $test_file
curl -i -H "x-auth-token: $HPAuth" https://region-b.geo-1.objects.hpcloudsvc.com/v1/$HP_PROJECT_ID/$container/$test_file_name -X PUT -T $test_file
