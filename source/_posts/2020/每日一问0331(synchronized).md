---
title:
---
# synchronized

### 谈谈 synchronized和ReenTrantLock 的区别

1) 都是可重入锁

2）synchronized 依赖于JVM ;ReenTrantLock 依赖于 API

3）ReenTrantLock 比sy 增加了一些高级功能

- 中断等待锁的线程机制
- 可以指定是公平锁还是非公平锁



说白了， volatile 关键字的主要作用就是保证变量的可见性然后还有一个作用是防止指令重排序。

### 说说 synchronized 关键字和 volatile 关键字的区别

- volatile关键字是线程同步的轻量级实现，所以volatile性能肯定比synchronized关键字要好。但是volatile关键字只能用于变量而synchronized关键字可以修饰方法以及代码块。synchronized关键字在JavaSE1.6之后进行了主要包括为了减少获得锁和释放锁带来的性能消耗而引入的偏向锁和轻量级锁以及其它各种优化之后执行效率有了显著提升，实际开发中使用 synchronized 关键字的场景还是更多一些。
多线程访问volatile关键字不会发生阻塞，而synchronized关键字可能会发生阻塞
- volatile关键字能保证数据的可见性，但不能保证数据的原子性。synchronized关键字两者都能保证。
- volatile关键字主要用于解决变量在多个线程之间的可见性，而 synchronized关键字解决的是多个线程之间访问资源的同步性。

### 锁升级 
![avator](http://ifeve.com/wp-content/uploads/2012/10/%E5%81%8F%E5%90%91%E9%94%81%E7%9A%84%E6%92%A4%E9%94%80.png)

![avator](http://ifeve.com/wp-content/uploads/2012/10/%E8%BD%BB%E9%87%8F%E7%BA%A7%E9%94%81.png)

参考:
[Java多线程--syncornized原理与应用](https://blog.csdn.net/hello_worldee/article/details/77823062)
