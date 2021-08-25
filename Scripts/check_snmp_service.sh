#!/bin/bash

########################################################################################
# Usage: check_snmp_service.sh host process                                            #
# This script will checks via SNMP a Linux hosts where it counts how many processess   #
# are active with the given name.                                                      #
# We had to check this for a customer where only SNMP is available.                    #
########################################################################################

host=$1
service=$2
snmpwalk -v2c -c public "$host" 1.3.6.1.2.1.25.4.2.1.2 | grep -c "$service"
