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

dnf module disable redis -y &>> $LOG_file
validate $? "disabling default version"

dnf module enable redis:7 -y &>> $LOG_file
validate $? "enabling redis-7"

dnf install redis -y &>> $LOG_file
validate $? "redis installation"

sed -i -e 's/127.0.0.1/0.0.0.0' -e '/protected-mode/c\protected-mode no' /etc/redis/redis.conf &>> $LOG_file
validate $? "modifying conf file"

systemctl enable redis &>> $LOG_file
validate $? "enabling redis"

systemctl start redis &>> $LOG_file
validate $? "starting redis"


