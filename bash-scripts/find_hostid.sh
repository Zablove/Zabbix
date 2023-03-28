#!/bin/bash

#Provide auth token and id for token:
token='12345'
id='1'

#Provide Zabbix API URL:
zabbixapi='https://zabbix.host/api_jsonrpc.php'


#Provide input file with one hostname per line:
filename='hosts.txt'

while read p; do
curl -X POST -k -s -H 'Content-Type:application/json' -d '{ "jsonrpc": "2.0", "method": "host.get", "params": { "filter": { "host": [ "'"$p"'" ] } }, "auth":"'"$token"'", "id": '"$id"' }' $zabbixapi | jq .result[].hostid | sed 's/\"//g'
done <$filename
