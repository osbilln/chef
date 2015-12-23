#!/bin/bash

mysql -u root -h localhost -p$1 mysql -e "stop slave;"
sleep(5)
mysql -u root -h localhost -p$1 mysql -e "change master to MASTER_HOST='';"
sleep(5)
mysql -u root -h localhost -p$1 mysql -e "reset slave;"

