#!/bin/bash

#########################################################################
# Script to force check of all items at host                            #
#                                                                       #
# Make sure to create user with access to API, define username and      #
# password in the variables below.                                      #
#                                                                       #
# In Zabbix Frontend, Administration -> Scripts, create new script      #
# In the commands section, point to the script and set variable to      #
# HOST.NAME. Example:                                                   #
# /usr/lib/zabbix/check.sh "{HOST.NAME}"                                #
#########################################################################

##Variables
zabbixusername="ZabbixAPIuser"
zabbixpassword="password_of_ZabbixAPIuser"
hostnm=$1

## Get Zabbix API Token
zabbixtoken=`curl -s -X POST -H 'Content-Type:application/json' -d '
{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "'$zabbixusername'",
        "password": "'$zabbixpassword'"
    },
    "id": 6,
    "auth": null
}' http://127.0.0.1/zabbix/api_jsonrpc.php \
| jq -r '.result'`

#Get hostid from hostname
output=`curl -s -X POST -H 'Content-type:application/json' -d '{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "selectGroups": "extend",
        "selectInterfaces": "extend",
        "filter": {
        "host" : [
         "'$hostnm'"
        ]
        }
        },
    "auth": "'$zabbixtoken'",
    "id": 6 }' http://127.0.0.1/zabbix/api_jsonrpc.php`

#Parse hostid to variable
hostid=$(echo $output | jq -r .result[0].hostid)


##Get the items of the host
hostitems=`curl -s -X POST -H 'Content-type:application/json' -d '{
    "jsonrpc": "2.0",
    "method": "item.get",
    "params": {
    "hostids": "'$hostid'"
        },
    "auth": "'$zabbixtoken'",
    "id": 6 }' http://127.0.0.1/zabbix/api_jsonrpc.php`

#countitems=$(echo $hostitems | jq -r '[.result[] | select (.master_itemid == "0") | {itemid}] | length')

#Get item numbers without master item (master items can't be checked)
items=$(echo $hostitems | jq -r '[.result[] | select (.master_itemid == "0") | {itemid}]')

#Count number of items to use in for loop
countitems=$(echo $items | jq '[.[]] | length')

#exectask=`curl -s -X POST -H 'Content-type:application/json' -d '{ "jsonrpc": "2.0", "method": "task.create", "params": [ { "type": "6", "request": { "itemid": "'$test'" } } ], "auth": "'$zabbixtoken'", "id": 6 }' http://127.0.0.1/zabbix/api_jsonrpc.php`

#Loop  trough all items and force check
i=0
while [[ $i -lt $countitems ]]
do
itemid=$(echo $items | jq '.['$i'] | .itemid' | sed 's/"//g')
#echo "$itemid"
curl -s -X POST -H 'Content-type:application/json' -d '{ "jsonrpc": "2.0", "method": "task.create", "params": [ { "type": "6", "request": { "itemid": "'$itemid'" } } ], "auth": "'$zabbixtoken'", "id": 6 }' http://127.0.0.1/zabbix/api_jsonrpc.php | grep "test"
((i = i + 1))
done
echo "Forced check of $countitems items"

## Close Zabbix Connection
closeconn=`curl -s -X POST -H 'Content-type:application/json' -d '{
        "jsonrpc": "2.0",
        "method": "user.logout",
        "params": [],
        "auth":"'$zabbixtoken'",
        "id":6
         }' http://127.0.0.1/zabbix/api_jsonrpc.php \
| jq -r '.result'`

if [ $closeconn != "true" ]
then
echo "Connection to Zabbix not proper closed"
else
echo -e "Script finished"
fi
