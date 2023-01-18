---
title:
---
# sentinel

## Hystrix 和 sentinel 区别

```
Hystrix is a library that helps you control the interactions between these distributed services by adding latency tolerance and fault tolerance logic. Hystrix does this by isolating points of access between the services, stopping cascading failures across them, and providing fallback options, all of which improve your system’s overall resiliency.
```

Hystrix 的关注点在于**以隔离和熔断为主的容错机制**，超时或被熔断的调用将会快速失败，并可以提供 fallback 机制。 

 Sentinel 的侧重点在于：

- 多样化的流量控制
- 熔断降级
- 系统负载保护
- 实时监控和控制台

## 参考

# [Sentinel源码解析一（流程总览）](https://www.cnblogs.com/taromilk/p/11750962.html)

[熔断降级](https://github.com/alibaba/Sentinel/wiki/%E7%86%94%E6%96%AD%E9%99%8D%E7%BA%A7)

