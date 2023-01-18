---
title:
---
# EDAS 测试输出文档

## 可借鉴功能

### 部署 自动挂载Java agent

默认自动挂载 Java Agent 进行精细化监控，并提供完整微服务治理方案（金丝雀发布、服务鉴权、限流/降级等）

服务监控

## 实现方式

### 服务监控

JVM监控，主机监控，调用链路监控， 可以集成skywalking到平台

![image-20210712110812197](C:\Users\zmk\AppData\Roaming\Typora\typora-user-images\image-20210712110812197.png)

## EDAS 架构设计

### 应用部署

针对Java 应用单独处理部署，增加了很多java 分布式应用很多特有处理，比如增加agent,Spring cloud 监控等等。

### 微服务空间设计

用来隔离各个k8s集群 应用组，适应不同的业务开发线吧

