# Maestrano Kafka
Docker image for Apache Kafka

## Build this docker image

* Build the image
`docker build -t docker-kafka ./0.10`

* Check that the image built
`docker images`

## Run a cluster

* Run the master image
`docker run -p 2181:2181 -p 9092:9092 --env ZK_CHROOT=kafka --env KAFKA_HOST=localhost --env KAFKA_PORT=9092 docker-kafka`

* Run a slave image
`docker run -p 9093:9092 --env ZK_MASTER=localhost:2181/kafka --env ZK_CHROOT=mno --env KAFKA_HOST=localhost --env KAFKA_PORT=9092 docker-kafka`