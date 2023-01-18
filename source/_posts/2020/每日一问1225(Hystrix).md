---
title:
---
# Hystrix

##　为啥需要隔离

例如，我们容器(Tomcat)配置的线程个数为1000，从服务A到服务R，其中服务I的并发量非常的大，需要500个线程来执行，此时，服务I又挂了，那么这500个线程很可能就夯死了，那么剩下的服务，总共可用的线程为500个，随着并发量的增大，剩余服务挂掉的风险就会越来越大，最后导致整个系统的所有服务都不可用，直到系统宕机。这就是服务的雪崩效应。Hystrix就是用来做资源隔离的，比如说，当客户端向服务端发送请求时，给服务I分配了10个线程，只要超过了这个并发量就走降级服务，就算服务I挂了，最多也就导致服务I不可用，容器的10个线程不可用了，但是不会影响系统中的其他服务。下面，我们就来具体说下这两种隔离策略：

## 隔离策略

* 线程池隔离 （默认）
* 信号量隔离

## 工作原理

  Hystrix 是一个帮助解决分布式系统交互时超时处理和容错的类库, 它同样拥有保护系统的能力。Netflix的众多开源项目之一。

   \1. **隔离**：

​      Hystrix隔离方式采用线程/信号的方式，通过隔离限制依赖的并发量和阻塞扩散

​      1)线程隔离

​      Hystrix在用户请求和服务之间加入了线程池。

​      Hystrix为每个依赖调用分配一个小的线程池，如果线程池已满调用将被立即拒绝，默认不采用排队.加速失败判定时间。线程数是可以被设定的。

​      原理：用户的请求将不再直接访问服务，而是通过线程池中的空闲线程来访问服务，如果线程池已满，则会进行降级处理，用户的请求不会被阻塞，至少可以看到一个执行结果（例如返回友好的提示信息），而不是无休止的等待或者看到系统崩溃。



   b）信号隔离：

​     信号隔离也可以用于限制并发访问，防止阻塞扩散, 与线程隔离最大不同在于执行依赖代码的线程依然是请求线程（该线程需要通过信号申请, 如果客户端是可信的且可以快速返回，可以使用信号隔离替换线程隔离,降低开销。信号量的大小可以动态调整, 线程池大小不可以。（参考文章2）

 \2. **熔断**：

如果某个目标服务调用慢或者有大量超时，此时，熔断该服务的调用，对于后续调用请求，不在继续调用目标服务，直接返回，快速释放资源。如果目标服务情况好转则恢复调用。

**熔断器:Circuit Breaker**

   熔断器是位于线程池之前的组件。用户请求某一服务之后，Hystrix会先经过熔断器，此时如果熔断器的状态是打开（跳起），则说明已经熔断，这时将直接进行降级处理，不会继续将请求发到线程池**。**==熔断器相当于在线程池之前的一层屏障。每个熔断器默认维护10个bucket ，每秒创建一个bucket ，每个blucket记录成功,失败,超时,拒绝的次数。当有新的bucket被创建时，最旧的bucket会被抛弃。==

​     熔断器的状态机：

​      ![img](https://images2015.cnblogs.com/blog/978381/201705/978381-20170516093016728-916759277.png)

- Closed：熔断器关闭状态，调用失败次数积累，到了阈值（或一定比例）则启动熔断机制；
- Open：熔断器打开状态，此时对下游的调用都内部直接返回错误，不走网络，但设计了一个时钟选项，默认的时钟达到了一定时间（这个时间一般设置成平均故障处理时间，也就是MTTR），到了这个时间，进入半熔断状态；
- Half-Open：半熔断状态，允许定量的服务请求，如果调用都成功（或一定比例）则认为恢复了，关闭熔断器，否则认为还没好，又回到熔断器打开状态； 

## 、流程

![img](https://images2015.cnblogs.com/blog/978381/201705/978381-20170516093153119-1533131398.png)

```
流程说明:
1``:每次调用创建一个新的HystrixCommand，把依赖调用封装在run()方法中。
2``:执行execute()/queue做同步或异步调用。
3``:判断熔断器(circuit-breaker)是否打开，如果打开跳到步骤``8，``进行降级策略，如果关闭进入步骤。
4``:判断线程池/队列/信号量是否跑满，如果跑满进入降级步骤``8，``否则继续后续步骤。
5``:调用HystrixCommand的run方法。运行依赖逻辑
5a:依赖逻辑调用超时，进入步骤``8。
6``:判断逻辑是否调用成功
6a:返回成功调用结果
6b:调用出错，进入步骤``8。
7``:计算熔断器状态，所有的运行状态(成功, 失败, 拒绝,超时)上报给熔断器，用于统计从而判断熔断器状态。
8``:getFallback()降级逻辑。
 ``以下四种情况将触发getFallback调用：
 ``(``1``)：run()方法抛出非HystrixBadRequestException异常
 ``(``2``)：run()方法调用超时
 ``(``3``)：熔断器开启拦截调用
 ``(``4``)：线程池/队列/信号量是否跑满
8a:没有实现getFallback的Command将直接抛出异常
8b:fallback降级逻辑调用成功直接返回
8c:降级逻辑调用失败抛出异常
9``:返回执行成功结果
```

## 六、代码实现

jar包：

**hystrix包**

```
<dependency>`` 
``<groupId>com.netflix.hystrix</groupId>``  
``<artifactId>hystrix-core</artifactId>`` 
``<version>``1.4``.``21``</version>``
</dependency>
```

**设置参数** 展开原码

 

| 参数                                                         | 作用                                                     | 备注                                                         |
| ------------------------------------------------------------ | -------------------------------------------------------- | ------------------------------------------------------------ |
| circuitBreaker.errorThresholdPercentage                      | 失败率达到多少百分比后熔断                               | 默认值：50主要根据依赖重要性进行调整                         |
| circuitBreaker.forceClosed                                   | 是否强制关闭熔断                                         | 如果是强依赖，应该设置为true                                 |
| circuitBreaker.requestVolumeThreshold                        | 熔断触发的最小个数/10s                                   | 默认值：20                                                   |
| circuitBreaker.sleepWindowInMilliseconds                     | 熔断多少秒后去尝试请求                                   | 默认值：5000                                                 |
| commandKey                                                   |                                                          | 默认值：当前执行方法名                                       |
| coreSize                                                     | 线程池coreSize                                           | 默认值：10                                                   |
| execution.isolation.semaphore.maxConcurrentRequests          | 信号量最大并发度                                         | SEMAPHORE模式有效，默认值：10                                |
| execution.isolation.strategy                                 | 隔离策略，有THREAD和SEMAPHORE                            | 默认使用THREAD模式，以下几种可以使用SEMAPHORE模式：只想控制并发度外部的方法已经做了线程隔离调用的是本地方法或者可靠度非常高、耗时特别小的方法（如medis） |
| execution.isolation.thread.interruptOnTimeout                | 是否打开超时线程中断                                     | THREAD模式有效                                               |
| execution.isolation.thread.timeoutInMilliseconds             | 超时时间                                                 | 默认值：1000在THREAD模式下，达到超时时间，可以中断在SEMAPHORE模式下，会等待执行完成后，再去判断是否超时 |
| execution.timeout.enabled                                    | 是否打开超时                                             |                                                              |
| fallback.isolation.semaphore.maxConcurrentRequests           | fallback最大并发度                                       | 默认值：10                                                   |
| groupKey                                                     | 表示所属的group，一个group共用线程池                     | 默认值：getClass().getSimpleName();                          |
| maxQueueSize                                                 | 请求等待队列                                             | 默认值：-1如果使用正数，队列将从SynchronizeQueue改为LinkedBlockingQueue |
| hystrix.command.default.metrics.rollingStats.timeInMilliseconds | 设置统计的时间窗口值的，毫秒值                           | circuit break 的打开会根据1个rolling window的统计来计算。若rolling window被设为10000毫秒，则rolling window会被分成n个buckets，每个bucket包含success，failure，timeout，rejection的次数的统计信息。默认10000 |
| hystrix.command.default.metrics.rollingStats.numBuckets      | 设置一个rolling window被划分的数量                       |                                                              |
| hystrix.command.default.metrics.healthSnapshot.intervalInMilliseconds | 记录health 快照（用来统计成功和错误绿）的间隔，默认500ms |                                                              |