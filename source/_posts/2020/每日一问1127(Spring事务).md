---
title:
---
# Spring 事务
## 事务传播属性

- REQUIRED 支持当前事务，如果没有事务会创建一个新的事务
- SUPPORTS 支持当前事务，如果没有事务的话以非事务方式执行
- MANDATORY 支持当前事务，如果没有事务抛出异常
- REQUIRES_NEW 创建一个新的事务并挂起当前事务

## 事务隔离级别 



## Springboot 2.3 + 为啥不需要加 EnableTransactionManagement
## 参考
* [【springboot】为何不使用@EnableTransactionManagement就能使用事务？](https://blog.csdn.net/qq_32370913/article/details/105924209)

* [Springboot源码分析之@Transactional](https://www.cnblogs.com/qinzj/p/11420840.html)F

