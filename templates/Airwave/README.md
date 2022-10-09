# Airwave AP discovery

The script airwave.sh will logon to the Airwave controller and create an auth cookie if the cookie file is older then 24h. After logon, the script will read out all AP's and status and save it in JSON format. 

Template will discover all AP's and create them as item. Will read the status of the IP with checkap.sh to prevent a status request for each AP everytime the status need to be read. 

Make sure zabbix user has rights to /tmp/hjar and /tmp/cjar for cookie.

