---
title: 
---
# redis

## 基础
### redis 简介
         存在内存中，读写速度非常快，用于缓存，分布式锁，除此之外，redis 支持事务 、持久化、LUA脚本、LRU驱动事件、多种集群方案。

### redis 的线程模型
         redis 内部使用 文件事件处理器 file event handler ，这个处理器是单线程的，所以叫单线程模型。采用 IO多路复用机制同时监听多个socket ，根据socket 事件选择对应的事件处理器。
         test11
         文件事件处理器包括4部分:
         - 多个socket
         - IO多路复用程序
         - 文件事件分派器
         - 事件处理器(连接应答处理器/命令请求处理器/命令回复处理器)
         多个 socket 可能会并发产生不同的操作，每个操作对应不同的文件事件，但是 IO 多路复用程序会监听多个 socket，会将 socket 产生的事件放入队列中排队，事件分派器每次从队列中取出一个事件，把该事件交给对应的事件处理器进行处理。
         ![avatar](https://www.javazhiyin.com/wp-content/uploads/2018/12/redis-single-thread-model.png)
### 为啥 redis 单线程模型也能效率这么高？
         - 纯内存操作
         - 核心是基于非阻塞的 IO 多路复用机制
         - 单线程反而避免了频繁的上下文切换
### redis 线程模型
         内部使用 file event handler ，这个事件处理器是单线程的，所以 redis 单线程 模型，
         
         IO多路复用，同时监听多个socket
### redis 和 memcached 的区别
         - redis 支持更丰富的数据类型
         - redis 支持数据的持久化  ,memercache 重启丢失
         - 集群模式 保证高可用
         - memecached 多线程 非阻塞 IO复用 模型，redis 单线程 IO多路复用模型
### 几种数据结构
         字符串String、字典Hash、列表List、集合Set、有序集合SortedSet。
         高级用法：
         - HyperLogLog 供不精确的去重计数功能，比较适合用来做大规模数据的去重统计，例如统计 UV；             
         - Bitmap 位图是支持按 bit 位来存储信息，可以用来实现 布隆过滤器（BloomFilter）；
         - GeoHash  可以用来保存地理位置，并作位置距离计算或者根据半径计算位置等。有没有想过用Redis来实现附近的人？
         - Pub/Sub 功能是订阅发布功能，可以用作简单的消息队列。
         - Pipeline    可以批量执行一组指令，一次性返回全部结果，可以减少频繁的请求应答。     
### pub/sub有什么缺点？
         在消费者下线的情况下，生产的消息会丢失，得使用专业的消息队列如RocketMQ等。


### Zset 原理(跳跃表)
         跳跃表性质如下：
         - 一个跳表由很多层组成
         - 每一层都是一个有序的链表
         - 最底层的链表(Level 1)包含所有的元素
         - 如果一个元素出现在Level i层的链表中，则在Level i层以下的所有层都将包含该元素
         - 每个节点包含key及其对应的value和一个指向同一层链表的下个节点的指针数组
### 持久化   
         Redis 提供了 RDB 和 AOF 两种持久化方式，RDB是将全量数据集以快照形式写入磁盘，实际上是通过fork 子进程执行,采用二进制压缩存储;AOF以分别日志形式记录 redis 增量，  内存   
### 高可用
         哨兵(3个选举)+ 主从(RDB+AOF)

### 如何保证 缓存数据库双写数据一致性

         - 弱一致性 ，定时任务
         - 强一致性 ，串行化 ，但会影响性能

### 高可用部署
         - 主从
         - 哨兵（Sentinel）: 是一个集群，监控redis 节点，每隔一秒向master发送ping,如果再一段时间内收不到pong，则认为master 下线
         - cluster 集群部署 :采用去中心化的思想;它采用一定方式，在集群中分布存储;节点之间采用轻量协议通讯，减少带宽占用；自动实现负载均衡与高可用，自动实现 failover并且支持动态扩展；内部也需要配置主从，并且内部也是采用哨兵模式，如果集群中master没有slave节点，则master挂掉整个集群进入fail状态，因为集群slot映射补全，如果超过半数master挂掉也会进入fail

### 同步机制
         - 数据copy 从服务器接收同步命令，同步主服务器数据
         - 命令传播， 主服务器接收一条消息，发出同步命令，从服务器同步该条数据。
         2.8 之前 只要断线 就要复制 ，2.8 之后短时断线 从服务器根据偏移量部分重同步


​    
​         [redisson,jedis,Lettuce 三者的区别](https://www.cnblogs.com/liyan492/p/9858548.html)
​     理器/命令请求处理器/命令回复处理器)
​     多个 socket 可能会并发产生不同的操作，每个操作对应不同的文件事件，但是 IO 多路复用程序会监听多个 socket，会将 socket 产生的事件放入队列中排队，事件分派器每次从队列中取出一个事件，把该事件交给对应的事件处理器进行处理。
​     ![avatar](https://www.javazhiyin.com/wp-content/uploads/2018/12/redis-single-thread-model.png)
### BloomFilter 原理 
当一个元素被加入集合时，通过K个散列函数将这个元素映射成一个位数组中的K个点，把它们置为1。检索时，我们只要看看这些点是不是都是1就（大约）知道集合中有没有它了：如果这些点有任何一个0，则被检元素一定不在；如果都是1，则被检元素很可能在。这就是布隆过滤器的基本思想。


### Redis的过期策略
- 定期随机删除
- 惰性删除
- 内存淘汰 （（volatile-lru 尝试回收最少使用的键），LRU算法）

## 压缩列表



​    

### 缓存雪崩和穿透的解决方案

####缓存雪崩

同一时间缓存大面积失效，后面请求落到数据库上。

解决方法
- 事前: 保证 redis 集群高可用性，发现宕机尽快补上。选择合适的内存淘汰策略
- 事中: 本地 ehcache缓存+ hystrix 限流& 降级 ,避免 MySql 崩掉
- 事后： 利用 redis 持久化机制 保存的数据尽快恢复缓存 

### 缓存穿透
热点key 不在缓存中，导致请求直接到了 数据库上，


解决方法
- 缓存无效key 设置过期时间尽量短
- 布隆过滤器

```
当一个元素加入布隆过滤器中的时候，会进行如下操作：
   
   使用布隆过滤器中的哈希函数对元素值进行计算，得到哈希值（有几个哈希函数得到几个哈希值）。
   根据得到的哈希值，在位数组中把对应下标的值置为 1。
   当我们需要判断一个元素是否存在于布隆过滤器的时候，会进行如下操作：
   
   对给定元素再次进行相同的哈希计算；
   得到值之后判断位数组中的每个元素是否都为 1，如果值都为 1，那么说明这个值在布隆过滤器中，如果存在一个值不为 1，说明该元素不在布隆过滤器中。
```
## 如何部署高可用的Redis集群架构
[如何部署高可用的Redis集群架构](https://blog.csdn.net/huangshulang1234/article/details/78765308)



[redisson,jedis,Lettuce 三者的区别](https://www.cnblogs.com/liyan492/p/9858548.html)


## 命令
批量删除 测试
k run --namespace devops redis-client --rm --tty -i --restart='Never' --image 172.20.60.16:5000/library/redis:5.0.5-alpine --command -- redis-cli -h devops-redis-redis-ha   -a devops-redis  keys "ctfo:devplatform:gitlabUserToken*" | xargs redis-cli -a devops-redis del


redis-cli    -a devops-redis  keys "ctfo:devplatform:gitlabUserToken*" | xargs redis-cli -a devops-redis del

redis-cli  -a redis@2020  keys "ctfo:devplatform:gitlabUserToken*" | xargs redis-cli -a redis@2020 del

redis-cli  -a devops-redis  keys "ctfo:devplatform:gitlabUserToken*" | xargs redis-cli -a devops-redis del

## 参考

[压缩列表](https://www.cnblogs.com/hunternet/p/11306690.html)

[[Redis写时拷贝（COW）总结](https://www.cnblogs.com/jelly12345/p/15223184.html)]
