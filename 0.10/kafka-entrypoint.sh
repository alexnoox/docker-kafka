#!/bin/sh

# Optional ENV variables:
# * ZK_MASTER: the zookeeper cluster master, e.g. localhost:2181/kafka
# * ZK_CHROOT: the zookeeper chroot to be created by zookeeper and used by Kafka (without / prefix), e.g. "kafka"
# * SELF_HOST: the external ip for the container, e.g. `docker-machine ip \`docker-machine active\``
# * SELF_PORT: the external port for Kafka, e.g. 9092
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic
# * AUTO_CREATE_TOPICS: allow kafka to auto create topics (default is true)

echo "### Starting Kafka..."

# Set the kafka external host and port
if [ -n "$SELF_HOST" -a -n "$SELF_PORT" ]; then
    echo "### Kafka advertised.listeners: PLAINTEXT://$SELF_HOST:$SELF_PORT"
    if grep -q "^advertised.listeners" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s~#(advertised.listeners)=(.*)~\1=PLAINTEXT://$SELF_HOST:$SELF_PORT~g" $KAFKA_HOME/config/server.properties
    else
        echo "advertised.listeners=PLAINTEXT://$SELF_HOST:$SELF_PORT" >> $KAFKA_HOME/config/server.properties
    fi
fi

# Set the zookeeper master
if [ ! -z "$ZK_MASTER" ]; then
    echo "### Existing master zookeeper: $ZK_MASTER"
    sed -r -i "s~(zookeeper.connect)=(.*)~\1=${ZK_MASTER}~g" $KAFKA_HOME/config/server.properties
else
    # Set the zookeeper chroot
    if [ ! -z "$ZK_CHROOT" ]; then
        # Wait for zookeeper to start up
        until /usr/share/zookeeper/bin/zkServer.sh status; do
            sleep 0.1
        done

        # Create the chroot node
        echo "### Creating Zookeeper CHROOT $ZK_CHROOT"
        echo "create /$ZK_CHROOT \"\"" | /usr/share/zookeeper/bin/zkCli.sh || {
            echo "can't create chroot in zookeeper, exit"
            exit 1
        }

        echo "### New master zookeeper: localhost:2181/$ZK_CHROOT"
        sed -r -i "s/(zookeeper.connect)=(.*)/\1=localhost:2181\/$ZK_CHROOT/g" $KAFKA_HOME/config/server.properties
    fi
fi

# Allow specification of log retention policies
if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

# Configure the default number of log partitions per topic
if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

# Enable/disable auto creation of topics
if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $KAFKA_HOME/config/server.properties
fi

# Run Kafka
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
