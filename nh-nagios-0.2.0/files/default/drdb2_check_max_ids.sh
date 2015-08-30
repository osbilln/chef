#!/bin/bash

if [ "$#" -ne 6 ]; then
    echo "drdb2_check_max_ids.sh usage: <repl_db_host> <repl_db_user> <repl_db_pw> <master_db_host> <master_db_user> <master_db_pw>"
    exit
fi

REPL_DB_HOST=$1 
REPL_DB_USER=$2
REPL_DB_PW=$3
MASTER_DB_HOST=$4
MASTER_DB_USER=$5
MASTER_DB_PW=$6

#dbs=("citinew_staging" "comcastprod" "comcastprod_bonita_core" "comcastprod_bonita_history" "comcastprod_staging" "coxprod" "coxprod_bonita_core" "coxprod_bonita_history" "coxprod_staging" "usbankprod" "usbankprod_bonita_core" "usbankprod_bonita_history" "usbankprod_staging")
dbs=("usbankprod" "usbankprod_bonita_core" "usbankprod_bonita_history" "usbankprod_staging")

## now loop through the above array
for i in "${dbs[@]}"
do
    echo "checking ids on $i"
    status=`/usr/lib/nagios/plugins/check_max_id.rb $i $REPL_DB_HOST $REPL_DB_USER $REPL_DB_PW $MASTER_DB_HOST $MASTER_DB_USER $MASTER_DB_PW`
    if [ status -ne 0]; then
        exit(1)
    fi
done

exit(0)