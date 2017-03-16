#!/usr/bin/env bash

#set the variables
REGION="us-east-1"
MAINT_ASG_NAME="stg-web-plannedmaint"
#MAINT_ASG_NAME="tools-pf-labs-net-managers"
PROD_ASG_NAME="stg-web-2"
DESIRED_CAPACITY=1

#exit in case a command fails
set -o errexit

#check for AWS CLI to make sure it's in the PATH
command -v aws >/dev/null  || { echo "ERROR: aws is not in the $PATH. Exiting."; exit 1; }

#check for getopt presence
command -v getopt >/dev/null  || { echo "ERROR: getopt is not in the $PATH. Exiting."; exit 1; }

echo "Setting the $MAINT_ASG_NAME desired capacity to $DESIRED_CAPACITY"
aws autoscaling set-desired-capacity --auto-scaling-group-name "$MAINT_ASG_NAME" --desired-capacity $DESIRED_CAPACITY

#initialize to zero to force the while loop to execute
instanceCount=0
while [ "$instanceCount" -lt "$DESIRED_CAPACITY" ]; do
        echo "Checking for instance counts in the $MAINT_ASG_NAME"
        #get a list of all instances spun up as a result of desired-capacity increase
        #we need backticks to ensure the instances variable is cast as an array
        instances=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $MAINT_ASG_NAME | grep InstanceId | awk '{print $2}' | sed s/\"//g | sed s/\,//g`
        instanceCount=`echo $instances | wc -w`
        echo Current instance count is "$instanceCount" desired count is $DESIRED_CAPACITY
        sleep 5
done

echo "Found $instances in the $MAINT_ASG_NAME"

#get the second field, remove trailing carriage return
echo "Discovering the ELBs attached to $PROD_ASG_NAME"
elbList=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $PROD_ASG_NAME --output=text | grep LOADBALANCERNAMES | awk '{print $2}' | tr '\n' ' ')
echo "Discovered $elbList"

for elb in $elbList
do
        echo Attaching $elb to $MAINT_ASG_NAME
        aws autoscaling attach-load-balancers --load-balancer-names "$elb" --auto-scaling-group-name "$MAINT_ASG_NAME"
done

echo "Waiting until $instances pass the healthcheck for the $elbList ELBs"
for elb in $elbList
do
        echo checking $elb to make sure healthchecks are passed for all instance IDs $instances
        #echo aws elb wait instance-in-service --load-balancer-name $elb --instances $instances
        #loop until the wait command actually enters the wait state
        #if we start too early, it throws an error 255 because the instances are not yet showing
        #as being in progress for ELB attachment
        until aws elb wait instance-in-service --load-balancer-name $elb --instances $instances; do
                echo Not seeing $instances in the $elb yet
                sleep 5
        done
done

echo "All instances are in the ELBs!"
echo "Detaching $elbList from $PROD_ASG_NAME"
for elb in $elbList
do
        echo detaching $elb
        aws autoscaling detach-load-balancers --load-balancer-names "$elb" --auto-scaling-group-name "$PROD_ASG_NAME"
done
