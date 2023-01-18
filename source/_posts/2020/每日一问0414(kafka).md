---
title:
---

# kafka



## 部署

```shell
version: '2'
services:
  zookeeper:
    image: wurstmeister/zookeeper:latest
    hostname: zookeeper
    container_name: zookeeper
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    #定义挂载点         
    volumes:
      - /etc/localtime:/etc/localtime
  kafka:
    image: wurstmeister/kafka:2.11-0.11.0.3
    hostname: kafka
    container_name: kafka
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      KAFKA_ADVERTISED_HOST_NAME: "172.20.60.23"
      KAFKA_ADVERTISED_PORT: "9092"
    #定义挂载点         
    volumes:
      - /etc/localtime:/etc/localtime
```



```shell
//创建topic
bin/kafka-topics.sh --create --zookeeper 172.20.60.23:2181 --replication-factor 1 --partitions 1 --topic mykafka

//查看topic
bin/kafka-topics.sh --list --zookeeper 172.20.60.23:2181

//创建生产者
bin/kafka-console-producer.sh --broker-list 172.20.60.23:9092 --topic mykafka 

//创建消费者
kafka-console-consumer.sh --bootstrap-server 172.20.60.23:9092 --topic DEVOPS_PLATFORM_EVENT_TOPIC --from-beginning
//查看topic 分区
kafka-topics.sh --describe --bootstrap-server 127.0.0.1:9094  --topic count
//topic 分区增加到4个
kafka-topics.sh --bootstrap-server 127.0.0.1:9094 --alter --topic count --partitions 4
//topic 每个分区最新offset
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list localhost:9094 --topic count
//查看消费者组
kafka-consumer-groups.sh  --bootstrap-server 127.0.0.1:9094  --list
//查看消费者组里的消费者和消费信息
kafka-consumer-groups.sh  --bootstrap-server 127.0.0.1:9094 --describe  --group zmk-group

```



### confluent kafka 安装

有问题 待修复

部署参考   Quick Start for Apache Kafka using Confluent Platform (Docker)

```shell
# Start Zookeeper and expose port 2181 for use by the host machine
docker run -d --name zookeeper -p 2181:2181 confluent/zookeeper

# Start Kafka and expose port 9092 for use by the host machine
docker run -d --name kafka -p 9092:9092 --link zookeeper:zookeeper confluent/kafka

# Start Schema Registry and expose port 8081 for use by the host machine
docker run -d --name schema-registry -p 8081:8081 --link zookeeper:zookeeper \
    --link kafka:kafka confluent/schema-registry

# Start REST Proxy and expose port 8082 for use by the host machine
docker run -d --name rest-proxy -p 8082:8082 --link zookeeper:zookeeper \
    --link kafka:kafka --link schema-registry:schema-registry confluent/rest-proxy
```





## Spring-kafka 配置

```yaml
#################consumer的配置参数（开始）#################
#如果'enable.auto.commit'为true，则消费者偏移自动提交给Kafka的频率（以毫秒为单位），默认值为5000。
spring.kafka.consumer.auto-commit-interval;
 
#当Kafka中没有初始偏移量或者服务器上不再存在当前偏移量时该怎么办，默认值为latest，表示自动将偏移重置为最新的偏移量
#可选的值为latest, earliest, none
spring.kafka.consumer.auto-offset-reset=latest;
 
#以逗号分隔的主机：端口对列表，用于建立与Kafka群集的初始连接。
spring.kafka.consumer.bootstrap-servers;
 
#ID在发出请求时传递给服务器;用于服务器端日志记录。
spring.kafka.consumer.client-id;
 
#如果为true，则消费者的偏移量将在后台定期提交，默认值为true
spring.kafka.consumer.enable-auto-commit=true;
 
#如果没有足够的数据立即满足“fetch.min.bytes”给出的要求，服务器在回答获取请求之前将阻塞的最长时间（以毫秒为单位）
#默认值为500
spring.kafka.consumer.fetch-max-wait;
 
#服务器应以字节为单位返回获取请求的最小数据量，默认值为1，对应的kafka的参数为fetch.min.bytes。
spring.kafka.consumer.fetch-min-size;
 
#用于标识此使用者所属的使用者组的唯一字符串。
spring.kafka.consumer.group-id;
 
#心跳与消费者协调员之间的预期时间（以毫秒为单位），默认值为3000
spring.kafka.consumer.heartbeat-interval;
 
#密钥的反序列化器类，实现类实现了接口org.apache.kafka.common.serialization.Deserializer
spring.kafka.consumer.key-deserializer=org.apache.kafka.common.serialization.StringDeserializer
 
#值的反序列化器类，实现类实现了接口org.apache.kafka.common.serialization.Deserializer
spring.kafka.consumer.value-deserializer=org.apache.kafka.common.serialization.StringDeserializer
 
#一次调用poll()操作时返回的最大记录数，默认值为500
spring.kafka.consumer.max-poll-records;
#################consumer的配置参数（结束）#################
#################producer的配置参数（开始）#################
#procedure要求leader在考虑完成请求之前收到的确认数，用于控制发送记录在服务端的持久化，其值可以为如下：
#acks = 0 如果设置为零，则生产者将不会等待来自服务器的任何确认，该记录将立即添加到套接字缓冲区并视为已发送。在这种情况下，无法保证服务器已收到记录，并且重试配置将不会生效（因为客户端通常不会知道任何故障），为每条记录返回的偏移量始终设置为-1。
#acks = 1 这意味着leader会将记录写入其本地日志，但无需等待所有副本服务器的完全确认即可做出回应，在这种情况下，如果leader在确认记录后立即失败，但在将数据复制到所有的副本服务器之前，则记录将会丢失。
#acks = all 这意味着leader将等待完整的同步副本集以确认记录，这保证了只要至少一个同步副本服务器仍然存活，记录就不会丢失，这是最强有力的保证，这相当于acks = -1的设置。
#可以设置的值为：all, -1, 0, 1
spring.kafka.producer.acks=1
 
#每当多个记录被发送到同一分区时，生产者将尝试将记录一起批量处理为更少的请求， 
#这有助于提升客户端和服务器上的性能，此配置控制默认批量大小（以字节为单位），默认值为16384
spring.kafka.producer.batch-size=16384
 
#以逗号分隔的主机：端口对列表，用于建立与Kafka群集的初始连接
spring.kafka.producer.bootstrap-servers
 
#生产者可用于缓冲等待发送到服务器的记录的内存总字节数，默认值为33554432
spring.kafka.producer.buffer-memory=33554432
 
#ID在发出请求时传递给服务器，用于服务器端日志记录
spring.kafka.producer.client-id
 
#生产者生成的所有数据的压缩类型，此配置接受标准压缩编解码器（'gzip'，'snappy'，'lz4'），
#它还接受'uncompressed'以及'producer'，分别表示没有压缩以及保留生产者设置的原始压缩编解码器，
#默认值为producer
spring.kafka.producer.compression-type=producer
 
#key的Serializer类，实现类实现了接口org.apache.kafka.common.serialization.Serializer
spring.kafka.producer.key-serializer=org.apache.kafka.common.serialization.StringSerializer
 
#值的Serializer类，实现类实现了接口org.apache.kafka.common.serialization.Serializer
spring.kafka.producer.value-serializer=org.apache.kafka.common.serialization.StringSerializer
 
#如果该值大于零时，表示启用重试失败的发送次数
spring.kafka.producer.retries
#################producer的配置参数（结束）#################
#################listener的配置参数（结束）#################
#侦听器的AckMode,参见https://docs.spring.io/spring-kafka/reference/htmlsingle/#committing-offsets
#当enable.auto.commit的值设置为false时，该值会生效；为true时不会生效
spring.kafka.listener.ack-mode;
 
#在侦听器容器中运行的线程数
spring.kafka.listener.concurrency;
 
#轮询消费者时使用的超时（以毫秒为单位）
spring.kafka.listener.poll-timeout;
 
#当ackMode为“COUNT”或“COUNT_TIME”时，偏移提交之间的记录数
spring.kafka.listener.ack-count;
 
#当ackMode为“TIME”或“COUNT_TIME”时，偏移提交之间的时间（以毫秒为单位）
spring.kafka.listener.ack-time;
#################listener的配置参数（结束）#################
```



### 参考：

[Kafka的Consumer负载均衡算法](https://www.codercto.com/a/29055.html)

[Kafka 高性能吞吐揭秘](https://segmentfault.com/a/1190000003985468)

[kafka官方文档](https://kafka.apachecn.org/)

# [docker 安装kafka](https://www.cnblogs.com/hunternet/p/11017000.html)

 [Spring Kafka中关于Kafka的配置参数 ](https://blog.csdn.net/fenglibing/article/details/82117166)

 [关于消息队列Kafka的一些常见问题](https://blog.csdn.net/qq_35571554/article/details/82593159)

[Kafka 事务性之幂等性实现](http://matt33.com/2018/10/24/kafka-idempotent/)

[Quick Start for Apache Kafka using Confluent Platform (Docker)](https://docs.confluent.io/platform/current/quickstart/ce-docker-quickstart.html)

* ***** [Kafka-分区、片段、偏移量](https://zhuanlan.zhihu.com/p/137406991)
* 
