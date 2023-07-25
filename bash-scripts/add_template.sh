#!/bin/bash

# This script can be used to add xml templates to Zabbix. 
# Make sure to use xml templates or change script. 

#Provide auth token and id for token:
token='1234'
id='1'

#Provide Zabbix API URL:
zabbixapi='https://zabbix.url/api_jsonrpc.php'

#Provide template name
#Remove new lines and escape quotes in xml
zabbixtemplate=`cat template.xml | tr -d "\n" | sed 's/\"/\\\"/g'`

curl -X POST -s -H 'Content-Type:application/json' -d '{ "jsonrpc": "2.0", "method": "configuration.import", "params": { "format": "xml", "rules": { "templates": { "createMissing": true, "updateExisting": true }, "items": { "createMissing": true, "updateExisting": true, "deleteMissing": true }, "triggers": { "createMissing": true, "updateExisting": true, "deleteMissing": true }, "valueMaps": { "createMissing": true, "updateExisting": false } }, "source": "'"$zabbixtemplate"'" } , "auth":"'"$token"'", "id": "'"$id"'" }' $zabbixapi
