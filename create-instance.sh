#!/bin/bash
ami_id="ami-0220d79f3f480ecf5"
sg_id="sg-06ce163ff833036b8"
Hz_id="Z082049010RMR2FN1A4VI"
Domain_name="sowjanya.fine"

for instance in $@
do
instance_id=$(aws ec2 run-instances \
            --image-id $ami_id \
            --security-group-ids $sg_id\
            --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' \
            --instance-type t3.micro \
            --query 'Instances[0].InstanceId' \
            --output text)

if  [ $instance -eq frontend ] ; then
    ip=$(aws ec2 describe-instances \
         --instance-ids $INSTANCE_ID \
         --query 'Reservations[].Instances[].PublicIpAddress' \
         --output text)
    record_name="$Domain_name"
else
    ip=$(aws ec2 describe-instances \
         --instance-ids $INSTANCE_ID \
         --query 'Reservations[].Instances[].PrivateIpAddress' \
         --output text)
    record_name="$instance.$Domain_name"
fi
    echo "ip address: $ip"

aws route53 change-resource-record-sets \
--hosted-zone-id $Hz_id \
--change-batch '{
  "Comment": "Creating an A record",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$record_name'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "'$ip'"
          }
        ]
      }
    }
  ]
  }
  '
    echo "record updated for instance $instance"
  done