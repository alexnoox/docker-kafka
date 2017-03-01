# Maestrano Kafka
Docker image for Apache Kafka

## Build and run this docker image

* Build it
`docker build -t docker-kafka ./0.10`

* Run the master container
`docker run -p 2181:2181 -p 9092:9092 --env ZK_CHROOT=kafka --env SELF_HOST=localhost --env SELF_PORT=9092 docker-kafka`

* Run a slave container
`docker run -p 2181:2181 -p 9092:9092 --env ZK_MASTER=ip:port/kafka --env SELF_HOST=localhost --env SELF_PORT=9092 docker-kafka`

## Basic usage

```
export KAFKA=localhost:9092
export ZOOKEEPER=localhost:2181/kafka

# List kafka brokers
zookeeper-shell $ZOOKEEPER <<< "ls /brokers/ids"

# Manipulate topics
kafka-topics --create --zookeeper $ZOOKEEPER -replication-factor 1 --partitions 1 --topic test
kafka-topics --list --zookeeper $ZOOKEEPER
kafka-topics --describe --zookeeper $ZOOKEEPER --topic test

# Produce and consume events
kafka-console-producer --broker-list $KAFKA --topic test
kafka-console-consumer --bootstrap-server $KAFKA --topic test --from-beginning

```