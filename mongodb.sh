#!/bin/bash

LOG_DIR=/var/log/roboshop-shell
LOG_file=/var/log/roboshop-shell/$0.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

user_id=$(id -u)
echo "user id is: $user_id"

if [ $user_id -ne 0 ]; then
echo -e " $R pls run this with root user privileges $N" | tee -a $LOG_file
exit 1
fi

mkdir -p $LOG_DIR

validate() {
    if [ $1 -eq 0 ] ; then
    echo -e " $2 ... $G success $N" | tee -a $LOG_file
else 
    echo -e " $2 ... $R failure $N" | tee -a $LOG_file
    exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying repo"

dnf install mongodb-org -y &>> $LOG_file
validate $? "installing mongodb" 

systemctl enable mongod &>> $LOG_file
validate $? "enabling mongodb"

systemctl start mongod &>> $LOG_file
validate $? "starting mongodb"

sed -i  's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_file
validate $? "modifying ip"

systemctl restart mongod &>> $LOG_file
validate $? "restarting mongodb"