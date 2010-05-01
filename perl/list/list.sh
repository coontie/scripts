#!/bin/bash

serverList="dev uat prod"

for srv in $serverList
do
    tibemsadmin -server "tcp://cib-${srv}ems01:7222" -user admin -password Sen4@pp3 -script /tmp/list.txt
    tibemsadmin -server "tcp://cib-${srv}ems02:7222" -user admin -password Sen4@pp3 -script /tmp/list.txt
    tibemsadmin -server "tcp://cib-${srv}ems05:7222" -user admin -password Sen4@pp3 -script /tmp/list.txt
    tibemsadmin -server "tcp://cib-${srv}ems06:7222" -user admin -password Sen4@pp3 -script /tmp/list.txt
done
