#!/bin/bash

mysql -u root -h localhost -p$1 mysql -e "stop slave;"
mysql -u root -h localhost -p$1 mysql -e "change master to MASTER_HOST='';"
mysql -u root -h localhost -p$1 mysql -e "reset slave;"

