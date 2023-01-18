---
title:
---
# threadlocal

1. lock 的资源是多个线程共享的，所以访问的时候需要加锁。
2. ThreadLocal 是每个线程都有一个副本，是不需要加锁的。
3. lock 是通过时间换空间的做法。
4. ThreadLocal 是典型的通过空间换时间的做法。



值真正是放在ThreadLocalMap 中存取的，ThreadLocalMap 内部类有一个Entry 类，key是ThreadLocal 对象，value 就是你要存放的值，上面的代码value 存放的就是hello word。ThreadLocalMap 和HashMap的功能类似，但是实现上却有很大的不同：

1. HashMap 的数据结构是数组+链表
2. ThreadLocalMap的数据结构仅仅是数组
3. HashMap 是通过链地址法解决hash 冲突的问题
4. ThreadLocalMap 是通过开放地址法来解决hash 冲突的问题
5. HashMap 里面的Entry 内部类的引用都是强引用
6. ThreadLocalMap里面的Entry 内部类中的key 是弱引用，value 是强引用

看源码,

![img](http://5b0988e595225.cdn.sohucs.com/images/20191026/7ed07e788f7048949cbea7c5842d7209.png)



**链地址法和开放地址法的优缺点**

开放地址法：

1. 容易产生堆积问题，不适于大规模的数据存储。
2. 散列函数的设计对冲突会有很大的影响，插入时可能会出现多次冲突的现象。
3. 删除的元素是多个冲突元素中的一个，需要对后面的元素作处理，实现较复杂。

链地址法：

1. 处理冲突简单，且无堆积现象，平均查找长度短。
2. 链表中的结点是动态申请的，适合构造表不能确定长度的情况。
3. 删除结点的操作易于实现。只要简单地删去链表上相应的结点即可。
4. 指针需要额外的空间，故当结点规模较小时，开放定址法较为节省空间。

**ThreadLocalMap 采用开放地址法原因**ThreadLocal 中看到一个属性 HASH_INCREMENT = 0x61c88647 ，0x61c88647 是一个神奇的数字，让哈希码能均匀的分布在2的N次方的数组里, 即 Entry[] table，关于这个神奇的数字google 有很多解析，这里就不重复说了ThreadLocal 往往存放的数据量不会特别大（而且key 是弱引用又会被垃圾回收，及时让数据量更小），这个时候开放地址法简单的结构会显得更省空间，同时数组的查询效率也是非常高，加上第一点的保障，冲突概率也低



**为什么要交换**

这里解释下为什么交换，我们先来看看如果不交换的话，经过设置值和清理过期对象，会是以下这张图

![img](http://5b0988e595225.cdn.sohucs.com/images/20191026/bb4730acefe44b0d99452953ab9ce4b3.png)

这个时候如果我们再一次设置一个key=15,value=new2 的值，通过f(15)=5,这个时候由于上次index=5是过期对象，被清空了，所以可以存在数据，那么就直接存放在这里了

![img](http://5b0988e595225.cdn.sohucs.com/images/20191026/d5451e3cf21a4610bb42a243a34fa6cb.png)

你看，这样整个数组就存在两个key=15 的数据了，这样是不允许的，所以一定要交换数据



------------

get 和 set 方法都有进行帮助 GC ，所以正常情况下是不会有内存溢出的，*但是如果创建了之后一直没有调用 get 或者 set 方法，还是有可能会内存溢出*

所以最保险的方法就是，使用完之后就及时 remove 一下，加快垃圾回收，就完美的避免了垃圾回收



## 个人记录

threadlocal 里有个 threadlocalMap, 它的存储是  key是本线程实例化的引用(this),value是要存储的值；它的结构只有一个数组；key存储使用的开放地址法，（当出现hash冲突，则取下一个不冲突的位置，有个值8864 保证hash均匀分布在2的N次方上，初始长度是16），当 有个值被释放了，之前冲突的值要替换位置，（替换发生在 get,set方法内部），当没有调用get/set方法 还是有可能造成内存泄漏；

## 参考

# [Java弱引用(WeakReference)的理解与使用](https://www.cnblogs.com/zjj1996/p/9140385.html)

[吃透ThreadLocal 源码的每一个细节和设计原理 ](https://www.sohu.com/a/349724415_99908665)

[阿粉昨天说我动不动就内存泄漏，我好委屈...](https://blog.csdn.net/javageektech/article/details/108543987)