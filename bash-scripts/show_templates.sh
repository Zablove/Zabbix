#!/bin/bash

#Provide auth token and id for token:
token='12345'
id='1'

#Provide Zabbix API URL:
zabbixapi='https://zabbix.host/api_jsonrpc.php'

#Provide file with one hostid per line:
filename='hostids.txt'

while read p; do
result=`curl -X POST -s -H 'Content-Type:application/json' -d '{ "jsonrpc": "2.0", "method": "host.get", "params": { "output": ["hostid"], "selectParentTemplates": [ "templateid", "name" ], "hostids": "'"$p"'" }, "auth":"'"$token"'", "id": '"$id"' }' $zabbixapi`
result1=`echo $result | jq '.result[].parentTemplates[].name'`
echo $result1
done <$filename
