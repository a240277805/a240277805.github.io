---
title:
---
# Spring boot 熔断
## WHY
 今天遇到一个线上问题，在发送 fengin 请求时，偶发一个问题 `could not be queued for execution and no fallback available.` 查了一下 发现是fegin 队列不够了。
#### 问题来了
 1. 为啥会队列不够，队列默认多少，怎么加入的队列 
 2. 怎个问题咋解决
 3. 关于熔断会不会有其他坑

 遇到问题首先想到的肯定是如何去解决，我也一样，开始百度一下，很简单找到了答案，增加一段hystrix 配置   
