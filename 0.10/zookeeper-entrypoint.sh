#!/bin/sh

# Get local internal docker ip
MY_IP=`awk 'NR==1 {print $1}' /etc/hosts` 
echo "### Starting Zookeeper..."

cat /etc/zookeeper/conf/zoo.cfg

# Run Kafka
/usr/share/zookeeper/bin/zkServer.sh start-foreground
