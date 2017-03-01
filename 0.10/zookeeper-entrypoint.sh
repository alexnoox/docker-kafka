#!/bin/sh

echo "### Starting Zookeeper..."

echo "### Zookeeper config:"
cat /etc/zookeeper/conf/zoo.cfg

# Run Kafka
/usr/share/zookeeper/bin/zkServer.sh start-foreground
