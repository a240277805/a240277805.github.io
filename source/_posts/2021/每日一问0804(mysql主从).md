---
title:
---
# mysql 主从

## 一个事务日志同步的完整过程
在备库B上通过change master命令，设置主库A的IP、端口、用户名、密码，以及要从哪个位置开始请求binlog，这个位置包含文件名和日志偏移量。

在备库B上执行start slave命令，这时候备库会启动两个线程，就是图中的io_thread和sql_thread。其中io_thread负责与主库建立连接。

主库A校验完用户名、密码后，开始按照备库B传过来的位置，从本地读取binlog，发给B。

备库B拿到binlog后，写到本地文件，称为中转日志（relay log）。

sql_thread读取中转日志，解析出日志里的命令，并执行。



### mysql binlog 三种格式(binlog_format)

*  statement(**SBR**) :SQL语句的原文，同步有风险，比如 delete limit ，不一致的情况,或者使用索引不一致

* row(**RBR**)：row格式的binlog里没有了SQL语句的原文，而是替换成了两个event：Table_map和Delete_rows。

  Table_map event，用于说明接下来要操作的表是test库的表t;

  Delete_rows event，用于定义删除的行为。

  需要借助**mysqlbinlog**工具，解析和查看binlog中的内容


*  mixed(**MBR**): MySQL自己会判断这条SQL语句是否可能引起主备不一致，如果有可能，就用row格式，否则就用statement格式。
MIXED说明:
 对于执行的SQL语句中包含now()这样的时间函数，会在日志中产生对应的unix_timestamp()*1000的时间字符串  



SBR 的优点：

历史悠久，技术成熟
binlog文件较小
binlog中包含了所有数据库更改信息，可以据此来审核数据库的安全等情况
binlog可以用于实时的还原，而不仅仅用于复制
主从版本可以不一样，从服务器版本可以比主服务器版本高


SBR 的缺点：

不是所有的UPDATE语句都能被复制，尤其是包含不确定操作的时候。
调用具有不确定因素的 UDF 时复制也可能出问题
使用以下函数的语句也无法被复制：
* LOAD_FILE()
* UUID()
* USER()
* FOUND_ROWS()
* SYSDATE() (除非启动时启用了 --sysdate-is-now 选项)
INSERT ... SELECT 会产生比 RBR 更多的行级锁
复制需要进行全表扫描(WHERE 语句中没有使用到索引)的 UPDATE 时，需要比 RBR 请求更多的行级锁
对于有 AUTO_INCREMENT 字段的 InnoDB表而言，INSERT 语句会阻塞其他 INSERT 语句
对于一些复杂的语句，在从服务器上的耗资源情况会更严重，而 RBR 模式下，只会对那个发生变化的记录产生影响
存储函数(不是存储过程)在被调用的同时也会执行一次 NOW() 函数，这个可以说是坏事也可能是好事
确定了的 UDF 也需要在从服务器上执行
数据表必须几乎和主服务器保持一致才行，否则可能会导致复制出错
执行复杂语句如果出错的话，会消耗更多资源

RBR 的优点：

任何情况都可以被复制，这对复制来说是最安全可靠的
和其他大多数数据库系统的复制技术一样
多数情况下，从服务器上的表如果有主键的话，复制就会快了很多
复制以下几种语句时的行锁更少：
* INSERT ... SELECT
* 包含 AUTO_INCREMENT 字段的 INSERT
* 没有附带条件或者并没有修改很多记录的 UPDATE 或 DELETE 语句
执行 INSERT，UPDATE，DELETE 语句时锁更少
从服务器上采用多线程来执行复制成为可能

RBR 的缺点：

binlog 大了很多
复杂的回滚时 binlog 中会包含大量的数据
主服务器上执行 UPDATE 语句时，所有发生变化的记录都会写到 binlog 中，而 SBR 只会写一次，这会导致频繁发生 binlog 的并发写问题
UDF 产生的大 BLOB 值会导致复制变慢
无法从 binlog 中看到都复制了写什么语句
当在非事务表上执行一段堆积的SQL语句时，最好采用 SBR 模式，否则很容易导致主从服务器的数据不一致情况发生

另外，针对系统库 mysql 里面的表发生变化时的处理规则如下：
如果是采用 INSERT，UPDATE，DELETE 直接操作表的情况，则日志格式根据 binlog_format 的设定而记录
如果是采用 GRANT，REVOKE，SET PASSWORD 等管理语句来做的话，那么无论如何都采用 SBR 模式记录
注：采用 RBR 模式后，能解决很多原先出现的主键重复问题。


## (双 M 结构)如果节点 A 同时是节点 B 的备库，相当于又把节点 B 新生成的 binlog 拿过来执行了一次，然后节点 A 和 B 间，会不断地循环执行这个更新语句，也就是循环复制了。这个要怎么解决呢？

每个库在收到从自己的主库发过来的日志后，先判断 server id，如果跟自己的相同，表示这个日志是自己生成的，就直接丢弃这个日志。

##　参考

## [深入解析Mysql 主从同步延迟原理及解决方案](https://www.cnblogs.com/fengff/p/11011702.html)

[mysql主从复制及binlog格式](https://blog.csdn.net/xyw145195/article/details/109438190)

[mysql中binlog_format模式与配置详细分析](https://www.jb51.net/article/125615.htm)