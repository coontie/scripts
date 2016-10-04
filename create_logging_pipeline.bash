#!/usr/bin/env bash

#set the variables
REGION="us-west-2"
ELB_NAME="ProdWest-Logstash-Ingest"
SNS_NAME="ProdWest-Logstash-SNS"
SQS_NAME="ProdWest-Logstash-SQS"
ELB_PROTOCOL="TCP"
ELB_PORT=5043
SUBNETS="subnet-67995f02 subnet-ca4c558c subnet-d1a045a6"
SECURITY_GROUPS="sg-0b76ef6e sg-a09536c5" #these are default and Logging SGs

function error_exit
{
#       ----------------------------------------------------------------
#       Function for exit due to fatal program error
#               Accepts 1 argument: string containing error message
#       ----------------------------------------------------------------
        echo "${RUN_COMMAND}: ${1:-"Unknown Error"}" 1>&2
        exit 1
}

#function check_return
#{
#       local retValue="$1"
#       local linenum="$2"
#       if $retValue; then
#               echo "Success!"
#       else
#               error_exit "Failed to execute at $linenum. Aborting"
#       fi
##}
#exit in case a command fails
set -o errexit

#make sure all variables are declared ahead of time
#set -o nounset

#check for AWS CLI to make sure it's in the PATH
command -v aws >/dev/null  || { echo "ERROR: aws is not in the $PATH. Exiting."; exit 1; }

echo "Creating the $ELB_NAME ELB"
aws elb create-load-balancer --load-balancer-name $ELB_NAME --scheme internal --security-groups $SECURITY_GROUPS --listeners Protocol=$ELB_PROTOCOL,LoadBalancerPort=$ELB_PORT,InstanceProtocol=$ELB_PROTOCOL,InstancePort=$ELB_PORT --region $REGION --subnets $SUBNETS
#check_return

echo "Creating the $SNS_NAME SNS"
topicArn="$(aws sns create-topic --name $SNS_NAME --region $REGION | jq -r '.TopicArn')"
echo $topicArn
#check_return

echo "Creating the $SQS_NAME SQS"
queueUrl="$(aws sqs create-queue --queue-name $SQS_NAME --region $REGION | jq -r '.QueueUrl')"
#check_return $? $LINENO
echo $queueUrl

echo "Getting the $SQS_NAME ARN"
queueArn=$(aws sqs get-queue-attributes --queue-url "$queueUrl" --attribute-names QueueArn --region $REGION | jq -r '.Attributes.QueueArn')

echo "Subscribe $SNS_NAME to $SQS_NAME"
aws sns subscribe --topic-arn "$topicArn" --protocol sqs --notification-endpoint "$queueArn" --region "$REGION"
