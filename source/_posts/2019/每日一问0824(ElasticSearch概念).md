---
title:
---
# ElasticSearch概念
在读下边文章的时候 ，就越接近使用了，然后需要了解几个概念



### Node
节点是单个服务器实例

云里面的每个白色正方形的盒子代表一个节点——Node。
![avatar](https://ss.csdn.net/p?https://mmbiz.qpic.cn/mmbiz_png/JdLkEI9sZffrWx0A45Her9bZODhNsSktOK6nnSfk9QGQMOJLZOMMl2wlYKd1uiaEibFsLjuQtEBeL8RyBa0Az7Zg/640)

### Index 索引
索引是具有相似特性的文档集合

索引由名称（必须全部为小写）标识

正排索引：从文档角度看其中的单词，表示每个文档都含有哪些单词，以及每个单词出现了多少次（词频）及其出现位置（相对于文档首部的偏移量）。

倒排索引：从单词角度看文档，标识每个单词分别在那些文档中出现(文档ID)，以及在各自的文档中每个单词分别出现了多少次（词频）及其出现位置（相对于该文档首部的偏移量）。

简单理解，
```$xslt
正排索引：id ---> value
倒排索引：value ---> id
```


在一个或者多个节点直接，多个绿色小方块组合在一起形成一个ElasticSearch的索引。
![avatar](https://ss.csdn.net/p?https://mmbiz.qpic.cn/mmbiz_png/JdLkEI9sZffrWx0A45Her9bZODhNsSkt7UsZDh1aXDyoRbWWa8oHibZd8vubYzovV8qKvhgVT7lON9ErMztVIDQ/640)

### Type类型
在索引中，可以定义一个或多个类型。类型是索引的逻辑类别/分区，其语义完全取决于您。一般来说，类型定义为具有公共字段集的文档。例如，假设你运行一个博客平台，并将所有数据存储在一个索引中。在这个索引中，您可以为用户数据定义一种类型，为博客数据定义另一种类型，以及为注释数据定义另一类型。
### Document文档
文档是可以被索引的信息的基本单位
### 分片
一个分片shard是一个最小级别的工作单元，仅保存了索引中所有数据的一部分。 
分片就是一个Lucene实例，并且它本身就是一个完整的搜索引擎。 
文档存储在分片中，并且在分片中被索引，但是程序不会直接与分片通信，而是与索引通信。
![avatar](https://ss.csdn.net/p?https://mmbiz.qpic.cn/mmbiz_png/JdLkEI9sZffrWx0A45Her9bZODhNsSktlFXc08okMNZY3Sf0VnW3sA4XqL4OuOcpf9s2rezuiaNgibjCic4Fz6FOQ/640)
Shard＝Lucene Index
![avatar](https://ss.csdn.net/p?https://mmbiz.qpic.cn/mmbiz_png/JdLkEI9sZffrWx0A45Her9bZODhNsSkt28GbibzNzQrNFeew94C5ick9vibJeEDibx25icX1lBsySicibnXtcIKicEHxNA/640)
### segment
在Lucene里面有很多小的segment，我们可以把它们看成Lucene内部的mini-index。

![avatar](https://ss.csdn.net/p?https://mmbiz.qpic.cn/mmbiz_png/JdLkEI9sZffrWx0A45Her9bZODhNsSktnicias3h1GlKBYMJlvhMgf4Px4IMibv6JA1wZ9odDITPVm40rKqqTWNPA/640)

### Segment内部

有着许多数据结构

* Inverted Index 倒排索引
* Stored Fields 
* Document Values  存储库
* Cache
![avatar](https://ss.csdn.net/p?https://mmbiz.qpic.cn/mmbiz_png/JdLkEI9sZffrWx0A45Her9bZODhNsSktmeru4dTVXOWCibzCmDeCAM1EPf9jaliaNu5EiaqzyNN1xy3EmTWykiclYQ/640)
### 最最重要的Inverted Index
Inverted Index主要包括两部分：

* 一个有序的数据字典Dictionary（包括单词Term和它出现的频率）。
* 与单词Term对应的Postings（即存在这个单词的文件）。
![avatar](https://ss.csdn.net/p?https://mmbiz.qpic.cn/mmbiz_png/JdLkEI9sZffrWx0A45Her9bZODhNsSktuhD1d9NU7HIcG3jr5x5DRTiczLW0lK9Gob4rYUyndiaoZAiafEuTGwo1g/640)
## elasticsearch的写入流程
### refresh
es接收数据请求时先存入内存中，默认每隔一秒会从内存buffer中将数据写入filesystem cache，这个过程叫做refresh；

### fsync
translog会每隔5秒或者在一个变更请求完成之后执行一次fsync操作，将translog从缓存刷入磁盘，这个操作比较耗时，如果对数据一致性要求不是跟高时建议将索引改为异步，如果节点宕机时会有5秒数据丢失;

### flush
es默认每隔30分钟会将filesystem cache中的数据刷入磁盘同时清空translog日志文件，这个过程叫做flush。

![avatar](https://img-blog.csdn.net/20180831120934971?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1JfUF9K/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)


### ES数据类型
![avatar](https://img-blog.csdn.net/20171030202032340?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGFveWFuZzM2MA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

