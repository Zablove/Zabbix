#!/bin/bash

#########################################################################
# Created by Zablove 10-10-22	                                        #
# Script to check how many hosts are in error at a given hostgroup.     #
# Script is used to create a host that fires if more than X hosts in    #
# group Y allerts to create a dependencie. For example:                 #
# Multiple accesspoints go down but no dependent switch is in monitoring#
# you can now make the accesspoints dependent on this host / item	    #
#                                                                       #
# Note: Script based on Zabbix 5.0 where its not possible to create     #
# permanent API token for user so you have to login/logout.             #
# from zabbix 6.0 U can also use permanent API token, this script is    #
# not prepared for this situation.                                      #
#########################################################################

##Variables
zabbixusername="ZABBIX_API_USER"
zabbixpassword="ZABBISPASSWORD"
hostgrp=$1

## Get Zabbix API Token
zabbixtoken=`curl -s --insecure -X POST -H 'Content-Type:application/json' -d '
{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "'$zabbixusername'",
        "password": "'$zabbixpassword'"
    },
    "id": 6,
    "auth": null
}' https://zabbixurl/zabbix/api_jsonrpc.php \
| jq -r '.result'`

## -> Werkt niet, dependencies worden niet meegenomen
#hostitems=`curl -s --insecure -X POST -H 'Content-type:application/json' -d '{
#    "jsonrpc": "2.0",
#    "method": "problem.get",
#    "params": {
#      "groupids": "'$hostgrp'",
#      "suppressed": false,
#      "acknowledged" : false,
#      "countOutput": "1"
#      },
#    "auth": "'$zabbixtoken'",
#    "id": 6 }' https://zabbixurl/zabbix/api_jsonrpc.php`

hostitems=`curl -s --insecure -X POST -H 'Content-type:application/json' -d '{
    "jsonrpc": "2.0",
    "method": "trigger.get",
    "params": {
      "groupids": "'$hostgrp'",
      "maintenance": false,
      "withLastEventUnacknowledged": 1,
      "active": 1,
      "skipDependent": 1,
      "only_true": 1,
      "countOutput": "1"
      },
    "auth": "'$zabbixtoken'",
    "id": 6 }' https://zabbixurl/zabbix/api_jsonrpc.php`

echo $hostitems | jq -r '.result'
## Close Zabbix Connection
closeconn=`curl -s --insecure -X POST -H 'Content-type:application/json' -d '{
        "jsonrpc": "2.0",
        "method": "user.logout",
        "params": [],
        "auth":"'$zabbixtoken'",
        "id":6
         }' https://zabbixurl/zabbix/api_jsonrpc.php \
| jq -r '.result'`

if [ $closeconn != "true" ]
then
echo "Connection to Zabbix not proper closed"
fi
