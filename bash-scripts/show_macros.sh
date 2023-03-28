#!/bin/bash

#Provide auth token and id for token:
token='12345'
id='1'

#Provide Zabbix API URL:
zabbixapi='https://zabbix.host/api_jsonrpc.php'

#Provide macro to find:
zabbixmacro='{$MACRO_TO_FIND}'

#Provide file whith hostids, one per line:
filename='hostids.txt'

while read p; do
result=`curl -X POST -s -H 'Content-Type:application/json' -d '{ "jsonrpc": "2.0", "method": "host.get", "params": { "output": ["hostid"], "selectMacros": [ "macro", "value" ], "hostids": "'"$p"'" }, "auth":"'"$token"'", "id": '"$id"' }' $zabbixapi`
result1=`echo $result | jq '.result[] | .macros[] | select( .macro == "'"$zabbixmacro"'" )' | grep value | sed 's/\"value\": \"//g' | sed 's/\"//g'`
echo -e "$p\t$result1" | sed 's/ //g'
done <$filename
