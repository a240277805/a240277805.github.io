---
title:
---
# dubbo
## 基础篇
Dobbo 服务调用过程
- 服务提供方(Provider)所在的应用在容器中启动并运行
- 服务 提供方(Provider)将自己要发布的服务注册到注册中心(Registry)
- 服务调用方(Consumer)启动后想注册中心订阅它想要调用的服务
- 注册中心(registry)存储着Provider注册的远程服务，并将其所管理的服务列表通知给服务调用方(Consumer)，且注册中心和提供方和调用方之间均保持长连接，可以获取Provider发布的服务的变化情况，并将最新的服务列表推送给Consumer
- Consumer根据从注册中心获得的服务列表，根据软负载均衡算法选择一个服务提供者（provider）进行远程服务调用，如果调用失败则选择另一台进行调用。（COnsumer会缓存服务列表，及时注册中心宕机也不妨碍进行远程服务调用）
- 监控中心(Monitor)对服务的发布和订阅进行监控和统计服务消费者和提供者，在内存中累计调用次数和调用时间，定时每分钟发送一次统计数据到监控中心(Monitor)；Monitor可以选择Zookeeper、Redis或者Multiast注册中心等，


## 问题
- 缓存如何更新
- 怎么集成netty
- 一个请求的整个过程
- 坑
- 用到的模块
- 和zk的交互
- Consumer 的负载均衡怎么做的

![avatar](https://img-blog.csdnimg.cn/20200301232431652.jpg) 



## 参考
[Dubbo3 简介](https://dubbo.apache.org/zh/docs/introduction/)