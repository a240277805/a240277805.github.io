---
title:
---
# eventbus



消息总线

# 什么时候用cloud bus

spring cloud bus在整个后端服务中起到联通的作用，联通后端的多台服务器。我们为什么需要他做联通呢？

后端服务器一般都做了集群化，很多台服务器，而且在大促活动期经常发生服务的扩容、缩容、上线、下线。这样，后端服务器的数量、IP就会变来变去，如果我们想进行一些线上的管理和维护工作，就需要维护服务器的IP。

比如我们需要更新配置、比如我们需要同时失效所有服务器上的某个缓存，都需要向所有的相关服务器发送命令，也就是调用一个接口。

你可能会说，我们一般会采用zookeeper的方式，统一存储服务器的ip地址，需要的时候，向对应服务器发送命令。这是一个方案，但是他的解耦性、灵活性、实时性相比消息总线都差那么一点。

总的来说，就是在我们需要把一个操作散发到所有后端相关服务器的时候，就可以选择使用cloud bus了。

# cloud bus能做什么

当前spring cloud bus提供了两个可用的接口:1./bus/env用于设置某一个配置项2./bus/refresh用于刷新所有绑定到刷新点的配置项。

这两个接口是使用spring boot actuator方式发布出来的（可以参见：深入[SpringBoot:自定义Endpoint](http://www.jianshu.com/p/9fab4e81d7bb)一文），接收到消息后会使用spring的stream框架（可以参考：张开涛的[解Spring事件驱动模型](http://jinnianshilongnian.iteye.com/blog/1902886)一文）把消息传播到所有注册的相关服务器。

## 参考

[SpringCloud系列教程 | 第八篇：Spring Cloud Bus 消息总线](https://www.cnblogs.com/babycomeon/p/11141160.html)

[spring cloud 中消息总线（bus）使用](https://buqutianya.blog.csdn.net/article/details/78698755?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-1.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromBaidu-1.control)

[spring cloud bus 扩展消息总线方法](https://www.jianshu.com/p/093ed9816993)