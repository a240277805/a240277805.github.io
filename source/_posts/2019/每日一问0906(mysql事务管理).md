---
title:
---
#  mysql 事务管理

## 概念
### ACID是衡量事务的四个特性：
* 原子性：（Atomicity）(同时)
* 一致性：（Consistency）(弱一致性，最终一致性)
* 隔离性：（Isolation）
* 持久性：（Durability）
### mysql 日志
MySQL的日志有很多种，如二进制日志、错误日志、查询日志、慢查询日志等，此外InnoDB存储引擎还提供了两种事务日志：redo log(重做日志)和undo log(回滚日志)
* binlog 
* Redo log
* Undo log (记录的是和执行语句相反的sql)

## 事务的执行过程
mysql 日志


## 原理
 1. undo log。实现`原子性`的关键，当发生回滚时，InnoDB会根据undo log的内容做与之前相反的工作
 2. 利用MVCC实现一致性非锁定读，这就有保证在同一个事务中多次读取相同的数据返回的结果是一样的，解决了`不可重复读`的问题
 3. 利用Gap Locks和Next-Key可以阻止其它事务在锁定区间内插入数据，因此解决了`幻读`问题
### 出现的问题
#### 更新丢失
#### 脏读
在一个事务中读到了另一个事务`未提交`的记录 
#### 幻读
 mysql 的幻读并非什么读取两次返回结果集不同，而是事务在插入事先检测不存在的记录时，惊奇的发现这些数据已经存在了，之前的检测读获取到的数据如同鬼影一般。
#### 不可重复读
一个事务读取`同一条(同一范围)记录`2次，得到的结果不一致
#### 死锁

### 事务隔离级别
* Read Uncommitted（读取未提交内容):这会带来脏读，幻读，不可重复读，基本没用
* Read Committed（读取提交内容）: ，但仍然存在不可重复读和幻读问题。
* Repeatable Read（可重读）:同一个事务中多次读取相同的数据返回的结果是一样的。其避免了脏读和不可重复读问题，但幻读依然存在。
* Serializable（可串行化）: 事务串行执行.

![avatar](https://user-gold-cdn.xitu.io/2018/8/27/1657927364adccc5)

### 用到的技术
#### 乐观锁
使用数据版本（Version）记录机制实现，这是乐观锁最常用的一种实现方式。何谓数据版本？即为数据增加一个版本标识，一般是通过为数据库表增加一个数字类型的 “version” 字段来实现。当读取数据时，将version字段的值一同读出，数据每更新一次，对此version值加一。当我们提交更新的时候，判断数据库表对应记录的当前版本信息与第一次取出来的version值进行比对，如果数据库表当前版本号与第一次取出来的version值相等，则予以更新，否则认为是过期数据。
解决更新丢失
#### 行锁(读锁、写锁)
RC级别，提供了读锁和写锁，解决了赃读问题。
#### 间隙锁
RR级别，在已有读锁和写锁的基础上，增加了gap锁，即间隙锁，解决了幻读的问题

对`批量操作较多`，且操作结果有要求的系统，需要使用RR级别，如果都是按主健单条处理数据，完全不需要这个级别。
#### MVCC
为了查询一些正在被另一个事务更新的行，并且可以看到它们被更新之前的值。
##### MVCC原理 
InnoDB会给数据库中的每一行增加三个字段，它们分别是DB_TRX_ID、DB_ROLL_PTR、DB_ROW_ID。
读取创建版本小于或等于当前事务版本号，并且删除版本为空或大于当前事务版本号的记录。
增,删,改 时 更新其版本号


### 快照读和当前读
* 快照读：读取的是快照版本，也就是历史版本
* 当前读：读取的是最新版本

普通的SELECT就是快照读，而UPDATE、DELETE、INSERT、SELECT ...  LOCK IN SHARE MODE、SELECT ... FOR UPDATE是当前读。

## 问题

### ACID问题：

* 为什么InnoDB能够保证原子性？用的什么方式？
* 为什么InnoDB能够保证一致性？用的什么方式？
* 为什么InnoDB能够保证持久性？用的什么方式？

### 隔离性里隔离级别的问题：

* 为什么RU级别会发生脏读，而其他的隔离级别能够避免？
* 为什么RC级别不能重复读，而RR级别能够避免？
* 为什么InnoDB的RR级别能够防止幻读？


## 参考
* [一篇文章带你学习分布式事务](https://www.infoq.cn/article/g1avP9FUA6CDOYRAlv4R)
* [讲清楚分布式事务选型：XA、2PC、TCC、Saga、阿里Seata](https://mp.weixin.qq.com/s?__biz=MzIxMzEzMjM5NQ==&mid=2651033136&idx=1&sn=9a91289141bf24bf242ada7e676f0ddb&chksm=8c4c5b34bb3bd2227d025f2c9f1043ed07594bd08072f41336fb591e479e444c3ffba5bf8582&scene=27#wechat_redirect)
* [深入分析MySQL InnoDB的事务ACID特性](https://mp.weixin.qq.com/s?__biz=MzIwMzY1OTU1NQ==&mid=2247484137&idx=1&sn=f79302b061418771fc413c4b19a6218e&chksm=96cd42a5a1bacbb3dc9f2b6cc923b6a1fb021e467b8c4726078b499cef576b80c0dd86a1c131&scene=27#wechat_redirect)
* [MySQL 乱七八糟的可重复读隔离级别实现](https://mp.weixin.qq.com/s?__biz=MzUzMTA2NTU2Ng==&mid=2247484915&idx=2&sn=a4c247a6bde0b3897be871a9706f3f1c&chksm=fa497a42cd3ef3541743cd9c835bf8a7a2100d0a0ab38ad63a4f943077f375e5bff75a937af9&scene=27#wechat_redirect)
* [一文了解InnoDB事务实现原理](https://zhuanlan.zhihu.com/p/48327345)
* [Mysql中的MVCC](https://blog.csdn.net/chen77716/article/details/6742128)
* `*****`[MySQL事务隔离级别的实现原理](https://www.cnblogs.com/cjsblog/p/8365921.html)
* `*****`[MySQL 加锁处理分析](http://hedengcheng.com/?p=771#_Toc374698312)
