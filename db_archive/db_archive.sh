#!/bin/bash

## archive *.gz files up to specified S3 bucket w/ object set to --storage-class STANDARD_IA
set -e

if [ "$#" -ne 4 ]; then
    echo "usage: db_archive.sh <s3 bucket name> <local directory path> <s3 directory name> <region>"
    exit
fi

aws s3 cp $2 s3://$1/$3/ --exclude "*" --include "*.gz" --recursive --region $4 --storage-class STANDARD_IA