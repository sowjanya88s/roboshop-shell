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

dnf module disable nodejs -y &>> $LOG_file
validate $? "disabling default version"

dnf module enable nodejs:20 -y &>> $LOG_file
validate $? "enabling version 20"

dnf install nodejs -y &>> $LOG_file
validate $? "installing nodejs"

id roboshop &>> $LOG_file
if [ $? -ne 0 ] ; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_file
    validate $? "creating roboshop user"
else
    echo "roboshop user already exists ... skipping"
fi

mkdir -p /app  &>> $LOG_file
validate $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>> $LOG_file
validate $? "downloading code"

cd /app &>> $LOG_file
validate $? "moving to app dir"

rm -rf /app/* &>> $LOG_file
validate $? "Removing existing code"

unzip /tmp/cart.zip &>> $LOG_file
validate $? "unzipping code"

npm install &>> $LOG_file
validate $? "installing dependancies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>> $LOG_file
validate $? "copying service file"

systemctl daemon-reload &>> $LOG_file
validate $? "reloading daemon"

systemctl enable cart  &>> $LOG_file
validate $? "enabling cart"

systemctl start cart &>> $LOG_file
validate $? "starting cart"


