#!/bin/bash

#####################################################################
# Script to monitor AP's status from Airwave controller result file #
# Created 14-06-2021 Zablove				                        #
#                                                                   #
# Make sure files /tmp/hjar and /tmp/cjar are writeable by zabbix   #
# user to update the API keys                                       #
# Input AP ID                                                       #
# Output codes:                                                     #
# 0 = geen data                                                     #
# 1 = Controller down        = alert                                #
# 2 = AP up, controller up                                          #
# 3 = AP down, controller down                                      #
# 4 = AP down, controller up = alert                                #
#####################################################################

ap=$1

statusap=$(jq '.[] | select(.id == '\"$ap\"') | .up ' /usr/lib/zabbix/externalscripts/aplist.json | sed 's/"//g' )
controller=$(jq '.[] | select(.id == '\"$ap\"') | .controllerid ' /usr/lib/zabbix/externalscripts/aplist.json | sed 's/"//g' )
statusctrl=$(jq '.[] | select(.id == '\"$controller\"') | .up ' /usr/lib/zabbix/externalscripts/aplist.json | sed 's/"//g' )
#Debugging info, uncomment for test
#echo "AP: $statusap Ctrl: $statusctrl"

status=0

#if [ "$statusap" == "up" && "$statusctrl" == ]; then

#check if its a controller
if [ -z "$statusctrl" ] ; then
        #if its a controller and status is down echo 1
        if [ "$statusap" == "down" ] ; then
        echo "1"
        #if its a controller and status is up echo 2
        elif [ "$statusap" == "up" ] ; then
        echo "2"
        fi
#check if ap and controller up, then echo 2
elif [[ "$statusap" == "up" && "$statusctrl" == "up" ]] ; then
echo "2"
#check if ap down and controller down, then echo 3
elif [[ "$statusap" == "down" && "$statusctrl" == "down" ]] ; then
echo "3"
#check if ap down and controller up, then echo 4
elif [[ "$statusap" == "down" && "$statusctrl" == "up" ]] ; then
echo "4"
fi
