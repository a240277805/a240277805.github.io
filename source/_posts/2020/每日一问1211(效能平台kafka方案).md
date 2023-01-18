---
title:
---
# 效能平台 kafka 方案

## 问题汇总

### 订阅发布的形式：

1.多消费者组的形式 

2.消费者接收消息后做消息总线分发。

### topic 定义  

1.DEVOPS_CACHE_TOPIC  

2.DEVOPS_AFFAIR_EVENT_TOPIC

### key 定义  

1.delete_event  update_event 

2.task_delete_event,defect_update_event

### 消息消费成功的定义：

1.消费者成功接收消息，抛给下游做处理，

2.消费者下游业务处理成功。

### 消息幂等如何处理：

1. 生产者幂等 1）配置参数
2. 消费者幂等 1）offset ,2) 业务幂等

### 顺序性消息消费需求 

1.需求来源 

2.实现形式

## 下游消费失败如何处理 

1. 定时补偿
2. 补偿方案如何实现
3. 消息重试
4. 对账发邮件提醒

## 参考

[如何保证Kafka消息不被重复消费?(如何保证消息消费时的幂等性)](https://blog.csdn.net/wwwwww33/article/details/105671038/)

[kafka消费消息时的幂等性](https://blog.csdn.net/u011439839/article/details/90115573)

[Kafka 事务性之幂等性实现](http://matt33.com/2018/10/24/kafka-idempotent/)

[kafka 知识整理](https://www.processon.com/view/5f8ee94763768906e67d835e#map)