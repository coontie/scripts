#!/bin/bash

#we need this to ensure errors are propagated downstream
#through all the pipes
set -o pipefail

#define the constants
connectionString="rs0/xxxxxxxxx:27017,xxxxxxxxx:27017,xxxxxxxxx:27017"
backupUserName=xxxxxxxxx
backupPassword=xxxxxxxxx
dateTimeStamp=$(date "+%Y.%m.%d-%H.%M.%S")
bucketName=xxxxxxxxx
environment=STG
fromAddress="xxxxxxxxx"
hostname=$(hostname)
archiveName=mongobackup-"$dateTimeStamp"-"$hostname".gz
currentYear=$(date "+%Y")
currentMonth=$(date "+%m")
s3path=s3://"$bucketName"/MongoDB/"$environment"/"$currentYear"/"$currentMonth"/"$archiveName"

#define the functions
#mongodump -u "$backupUserName" -p "$backupPassword" --host "$connectionString" --archive=mongo_dumps/"$archiveName" --gzip --oplog
function create_json_message {
  cat <<EOF > ./message.json
    {
     "Subject": {
       "Data": "ERROR: Failed Mongo database backup on $hostname",
       "Charset": "UTF-8"
    },
    "Body": {
       "Text": {
           "Data": "$DateTimeStamp: $1",
           "Charset": "UTF-8"
       }
     }
   }
EOF
}

function create_destination_email {
  cat <<EOF > ./destination.json
  {
    "ToAddresses":  ["xxxxxxxxx"],
    "BccAddresses": []
  }
EOF
}

function send_email {
  aws ses send-email --from "$fromAddress" --destination file://destination.json --message file://message.json
}

function error_handler {
 #Spaces in error messages trip up the field separator, so we are preserving the old one
 #and changing the IFS temporarily
 SAVEIFS=$IFSIFS=$(echo -en "\n\b")
 IFS=$(echo -en "\n\b")

 errMessage="$1"

 #log the error to /var/log/messages
 echo "$errMessage" | logger

 #create the json email body file for the aws ses with the passed error message
 create_json_message $errMessage

 #create the json destination file for the aws ses
 create_destination_email

 #send the email
 send_email
 IFS=$SAVEIFS
}

#capture all errors and stdout and send them all to syslog /var/log/messages
exec 1> >(logger -t "mongodump") 2> >(logger -t "mongodump")

mongodump -u "$backupUserName" -p "$backupPassword" --host "$connectionString" --archive --gzip --oplog | aws s3 cp - "$s3path"

if [ $? -ne 0 ]; then
    error_handler "There was an issue running mongodump on `hostname`"
    exit
fi

#mongodump -u "$backupUserName" -p "$backupPassword" --host "$connectionString" --out=mongo_dumps/"$archiveName"
