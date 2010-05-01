#!/bin/bash

routerList=`cat router.list.master`
#routerList=`cat router.list.md`
#location=configs_md
location=configs

for router in $routerList
do
    echo processing $router
	fileName=`echo $router | tr /: " " | awk '{print $2}'`
	tibrvcfg -login 'rvadmin:Sen4@pp3' -url $router dumpXML configs/$fileName.xml
	#tibrvcfg -login 'root:wh0ry0u' -url $router dumpXML $location/$fileName.xml
	grep router $location/$fileName.xml > /dev/null
	if [ "$?" = 1 ]; then
		echo $location/$fileName.xml has no routers -- deleting.
		rm $location/$fileName.xml
	fi
    echo ____________________
done
