#!/bin/bash

LOG_DIR=/var/log/roboshop-shell
LOG_file=/var/log/roboshop-shell/$0.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
mysql_host=mysql.sowjanya.fun

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

cp $SCRIPT_DIR  /etc/yum.repos.d/rabbitmq.repo &>> $LOG_file
validate $? "copying rabbitmq repo"

dnf install rabbitmq-server -y &>> $LOG_file
validate "installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOG_file
validate $? "enabling rabbitmq"

systemctl start rabbitmq-server &>> $LOG_file
validate $? "starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_file
validate $? "adding rabbitmq user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_file
validate $? "setting permisiions for user"

