#!/bin/bash 
COUNTER=0
while [  $COUNTER -lt 10 ]; do
	./generate_ems_status.sh
	sleep 300
done
