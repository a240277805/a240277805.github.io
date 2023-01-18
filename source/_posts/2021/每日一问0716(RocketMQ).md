---
title:
---
# RocketMQ 

## 延迟队列

优点：设计简单，把所有相同延迟时间的消息都先放到一个队列中，定时扫描，可以保证消息消费的有序性

缺点：定时器采用了timer，timer是单线程运行，如果延迟消息数量很大的情况下，可能单线程处理不过来，造成消息到期后也没有发送出去的情况

改进点：可以在每个延迟队列上各采用一个timer，或者使用timer进行扫描，加一个线程池对消息进行处理，这样可以提供效率

![img](https://upload-images.jianshu.io/upload_images/8068221-37191def50a029aa.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)



## 参考

[rocketmq实现延时队列](https://www.jianshu.com/p/c6a4ede528a8)