#!/bin/bash

serverList='cib-calypsorate1:8222 cib-calypsorate2:8222'

for server in $serverList
do
    #strip out : from the filenames
    fileName=`echo $server | sed 's/\:/\./g' | awk -F. '{print $1}'`

    #get the current time
    timeStamp=`date +'%T'`

    /opt/tibco/ems/bin/tibemsadmin -server tcp://$server -user admin -password Sen4@pp3 -script /home/ig/perl/graph/chart/script.ems > /tmp/$fileName

    pending=`grep "Pending Messages" /tmp/$fileName | awk -F: '{print $2}'`

    connections=`grep "Connections" /tmp/$fileName | awk -F: '{print $2}'`

    inbound=`grep "Inbound" /tmp/$fileName | awk -F: '{print $2}' | awk '{print $1}'`

    outbound=`grep "Outbound" /tmp/$fileName | awk -F: '{print $2}' | awk '{print $1}'`

    if [ "$pending" = "" ]; then
        echo "Got nothing" > /dev/null
    else
        echo $timeStamp,$pending,$connections,$inbound,$outbound >> /home/ig/perl/graph/chart/results/$fileName
        #remove the top line
        sed '1,1d' /home/ig/perl/graph/chart/results/$fileName > /tmp/$fileName.sed
        mv /tmp/$fileName.sed /home/ig/perl/graph/chart/results/$fileName
    fi
done

#generate the graphs
cd /home/ig/perl/graph/chart/
/home/ig/perl/graph/chart/graph.pl

#transfer the files
scp /home/ig/perl/graph/chart/graphs/cib-calypsorate* cib-labmsg01.usa.wachovia.net:/srv/www/htdocs/ems/graphs/
