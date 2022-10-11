# Zabbix
## Zabbix Scripts

## forcecheck.sh

Zabbix has the ability to create front-end scripts. These scripts run at the server or at a proxy or agent. 
The script forcecheck.sh forces a re-check of all items of the host. This can normally be done under the configuration of items, however in my case users don't have rights to this section and because of performance, some checks run once an hour. This is sometimes a long time if you want to see if your problem is resolved in Zabbix.

## check_snmp_service.sh

This script will checks via SNMP a Linux hosts where it counts how many processess are active with the given name. We had to check this for a customer where only SNMP is available.

## info.sh

Backend script to display some information about the host. 

## hostgroupcheck.sh

Script to check how many hosts are in error at a given hostgroup.

## tile.php

PHP Page that will generate a green (if no triggers active at hostgroups) tile or a red one (if triggers fired at hostgroups), also counter is added. Add transparent png image to display for example a customer logo. 
You also need the *green.png* and *red.png* in the same folder as a arial.ttf font file (not provided, you can find it at the internet). 
Also the file *ZabbixApi.php* is needed, note that this php need some dependencies (see file). For source of this file, see https://github.com/intellitrend/zabbixapi-php

## Zabbix Templates

## Airwave

Zabbix template and scripts to discover status of Accesspoints from Airwave controller, convert it to json and read status per AP. 

## Windows Failover Cluster

Template to monitor Windows Failover Cluster, checks if node is active at the right cluster node. 
