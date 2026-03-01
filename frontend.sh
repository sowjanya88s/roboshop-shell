#!/bin/bash

LOG_DIR=/var/log/roboshop-shell
LOG_file=/var/log/roboshop-shell/$0.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

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

dnf module disable nginx -y &>> $LOG_file
validate $? "disabling default nginx version"

dnf module enable nginx:1.24 -y &>> $LOG_file
validate $? "enabling nginx:1.24"

dnf install nginx -y &>> $LOG_file
validate $? "installing nginx"

systemctl enable nginx  &>> $LOG_file
validate $? "enabling nginx"

systemctl start nginx &>> $LOG_file
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_file
validate $? "removing default code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_file
validate $? "downloading code"

cd /usr/share/nginx/html &>> $LOG_file
validate $? "moving to code directory"

unzip /tmp/frontend.zip &>> $LOG_file
validate $? "unzipping the code"

cp $SCRIPT_DIR/nginx.conf  /etc/nginx/nginx.conf &>> $LOG_file
validate $? "copying conf file"

systemctl restart nginx &>> $LOG_file
validate $? "restarting nginx"

