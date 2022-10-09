#!/bin/bash
#####################################################################
# Script to discover and monitor AP's from Airwave controller API   #
# Created 14-06-2021 Zablove				                        #
#                                                                   #
# Make sure files /tmp/hjar and /tmp/cjar are writeable by Zabbix   #
# user to update the API keys                                       #
# Create read-only username at airwave controller and set right 	#
# credentials in first CURL request.								#
# Set right IP of controller in CURL request (see X.X.X.X)			#
#####################################################################

FILE=$1

#####################################################################
# Step 1, check if cookie is older than 8 hours                     #
# If cookie older than 8 hours (86400 seconds) renew cookie         #
#####################################################################

filename='/tmp/hjar'
filecreate=`stat -c %Y $filename`
currenttime=`date +%s`
cookieage=$(($currenttime - $filecreate))
if [ "$cookieage" -ge "600" ]
then
curl -s -k -D /tmp/hjar -c /tmp/cjar -d "credential_0=AIRWAVEUSER" -d "credential_1=AIRWAVEPASSW" -d "destination=/" -d "login=Log In" https://X.X.X.X/LO>
fi

#####################################################################
# Run script, remove XML tags and structure as JSON                 #
#####################################################################

result=`curl -s -k --header "X-BISCOTTI: /fakestring" -b /tmp/cjar https://X.X.X.X/ap_list.xml | grep "<name>\|<ap id=\|<is_up>" | sed 's/<\>
echo '['
echo $result | sed 's/.$//'
echo ']'
