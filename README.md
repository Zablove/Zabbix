# Zabbix
## Zabbix Scripts

** forcecheck.sh **
Zabbix has the ability to create front-end scripts. These scripts run at the server or at a proxy or agent. 
The script forcecheck.sh forces a re-check of all items of the host. This can normally be done under the configuration of items, however in my case users don't have rights to this section and because of performance, some checks run once an hour. 
