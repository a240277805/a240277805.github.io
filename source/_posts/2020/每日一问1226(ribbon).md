---
title:
---
# ribbon 

## ribbon 与 feign 关系

Feign是一个声明式的web service客户端，它使得编写web service客户端更为容易。

Ribbon是Netflix发布的开源项目，主要功能是提供客户端的软件负载均衡算法，将Netflix的中间层服务连接在一起。Ribbon客户端组件提供一系列完善的配置项如连接超时，重试等。简单的说，就是在配置文件中列出Load Balancer后面所有的机器，Ribbon会自动的帮助你基于某种规则（如简单轮询，随机连接等）去连接这些机器。我们也很容易使用Ribbon实现自定义的负载均衡算法。简单地说，Ribbon是一个客户端负载均衡器。

如果微服务项目加上了spring-cloud-starter-netflix-hystrix依赖，那么，feign会通过代理模式， 自动将所有的方法用 hystrix 进行包装。

在Spring Cloud微服务体系下，微服务之间的互相调用可以通过Feign进行声明式调用，在这个服务调用过程中Feign会通过Ribbon从服务注册中心获取目标微服务的服务器地址列表，之后在网络请求的过程中Ribbon就会将请求以负载均衡的方式打到微服务的不同实例上，从而实现Spring Cloud微服务架构中最为关键的功能即服务发现及客户端负载均衡调用。

### RestTemplate 为啥 加上 @LoadBalanced 就负载均衡了

### ribbon 源码解析





## 参考

[Ribbon详解](https://www.jianshu.com/p/1bd66db5dc46)