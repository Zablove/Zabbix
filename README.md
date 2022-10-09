# Zabbix
## Zabbix Scripts

__forcecheck.sh__

Zabbix has the ability to create front-end scripts. These scripts run at the server or at a proxy or agent. 
The script forcecheck.sh forces a re-check of all items of the host. This can normally be done under the configuration of items, however in my case users don't have rights to this section and because of performance, some checks run once an hour. This is sometimes a long time if you want to see if your problem is resolved in Zabbix.

__check_snmp_service.sh__

This script will checks via SNMP a Linux hosts where it counts how many processess are active with the given name. We had to check this for a customer where only SNMP is available.
