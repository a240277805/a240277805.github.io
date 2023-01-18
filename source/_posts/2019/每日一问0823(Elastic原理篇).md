---
title:
---
<h1>Elastic 原理篇</h1>
<h2>WHY</h2>

此文章参照 infoQ陶文大师的文章[时间序列数据库的秘密](时间序列数据库的秘密（一）)  根据自己的理解整理的 

<h3>时间序列数据</h3>
* 1.第一类格式 
[metric_name] [timestamp] [value]
 ```
SELECT value FROM metric WHERE metric_name=”A” AND timestamp >= B AND 
 ```
这种模式两个弊端
* 1.无法快速响应变化: 如果需要的图表有变更，需要从上报的源头重新来一遍。而且要等新数据过来之后，才能查看这些新数据。
* 2.存储膨胀：总有一些数据是需要从不同的维度查询的需求，比如广告点击流数据，需要按省份聚合，按运营商聚合，按点击人喜好组合，这些维度交叉组合存储起来又会造成空间浪费。


<h3>如何快速检索？</h3>

几个概念： `document docid  term `
* term dictionary ：排好序的 term 
* term index : `类似于一本字典的章节列表` 标记了 term dictionay 位置（存储在磁盘中）  `体积小 存储在内存中`，
 term index 是 一个tree 树: term 可以是任意的 byte 数组，然后每个 index 大小不一 这棵树不会包含所有的 
 * term，它包含的是 term 的一些前缀。通过 term index 可以快速地定位到 term dictionary 的某个 offset，然后从这个位置再往后顺序查找。再加上一些压缩技术（搜索 Lucene Finite State Transducers） term index 的尺寸可以只有所有 term 的尺寸的几十分之一
![avatar](https://static001.infoq.cn/resource/image/e4/26/e4599b618e270df9b64a75eb77bfb326.jpg)

<h3>ES 为什么比MySQL 快？</h3>

Mysql 只有 term dictionary 这一层，是以 b-tree 排序的方式存储在磁盘上的。检索一个 term 需要若干次的 random access 的磁盘操作。

1）Lucence 有 term index 加速检索 

2） 还有 存储在内存中 

3）term index 以树的形式缓存在内存中。

了解[FST](https://www.cnblogs.com/jiu0821/p/7688669.html)  
![avatar](https://images2017.cnblogs.com/blog/504727/201710/504727-20171018202211834-1358126860.jpg)

FST 为啥省内存??

   正因为，我们保证了所有的Key都是按照字典序加进来的，所以当加入一个新Key的时侯，我们可以先求出新加的Key和上一次输入的Key的公共前缀，然后就可以把 上一次输入的Key除去公共前缀剩下的部分存入文件中了。

如果想了解请查看Lucene4.0官方开源代码Builder.java 的add 方法。目前Lucene还支持FST的反映射，即通过Value找Key，以及前k小的Key（按照Value大小排序）。其实就是在FST上用`Dijikstra`求最短路。

额外值得一提的两点是：
* term index 在内存中是以 FST（finite state transducers）的形式保存的，其特点是非常节省内存。
* Term dictionary 在磁盘上是以分 block 的方式保存的，一个 block 内部利用公共前缀压缩（也是公共前缀压缩？），比如都是 Ab 开头的单词就可以把 Ab 省去。这样 term dictionary 可以比 b-tree 更节约磁盘空间。
### 数据写入流程
1. 新增的文档首先会放入内存的缓存中
2. 当文档足够多，或者到达一定时间点，就会对缓存进行commit
- 生成一个新的segment,并写入磁盘
- 生成一个新的commit point ,记录当前所有可用的segment
- 等待所有数据都已吸入磁盘

3、 打开新增segment,这样我们就可以对新增的文档进行搜索了。

4、 清空缓存，准备接受新的文档。
### 数据的删除和更新
- 删除 是标记删除 ，维护.del 文件，查询是加过滤
- 更新是先删除再插入新的。
### Refesh
ES 一个特性是提供实时搜索。在提交数据时，写入磁盘速度太慢，就先写入文件缓存，然后打开可供查询，然后再逐渐将文件flush 到磁盘。默认refresh频率是一秒，插入后没有refresh 是搜不到的可以手动触发refresh.
### flush 与 translog
当新插入的数据写入文件缓存，如果断电会丢失，所以新增加了 translog,每次写入记录translog,当translog足够大，或者时间够就flush 到磁盘，清空translog.


<h3>如何联合索引查询？</h3>

所以给定查询过滤条件 age=18 的过程就是先从 term index 找到 18 在 term dictionary 的大概位置，然后再从 term dictionary 里精确地找到 18 这个 term，然后得到一个 posting list 或者一个指向 posting list 位置的指针。然后再查询 gender= 女 的过程也是类似的。最后得出 age=18 AND gender= 女 就是把两个 posting list 做一个`“与”`的合并。

如何合并两个 posting list 
1. 使用 skip list 数据结构。同时遍历 gender 和 age 的 posting list，互相 skip；
2. 使用 `bitset` 数据结构，对 gender 和 age 两个 filter 分别求出 bitset，对两个 bitset 做 AN 操作。
`PostgreSQL 从 8.4 版本开始支持通过 bitmap 联合使用两个索引，就是利用了 bitset 数据结构来做到的。`



**`Elasticsearch` 支持以上两种的联合索引方式，如果查询的 filter 缓存到了内存中（以 bitset 的形式），那么合并就是两个 bitset 的 AND。如果查询的 filter 没有缓存，那么就用 skip list 的方式去遍历两个 on disk 的 posting list。**

<h4>利用 Skip List 合并</h4>

![avatar](https://static001.infoq.cn/resource/image/ea/9f/eafa46683272ff1b2081edbc8db5469f.jpg)

1. 从小到大排序，取最短的开始，然后跳过其他比这个小的；
2. 跳跳跳
3. 原理 ？？？？自己写的 ，跳表原来好像不同 需要了解

多条序列
1. 从小到大排序，
2. 取最短一条序列开始
3. 确定多个序列的跳过位置0，确定初始值 （最短序列开始第一个值）
4. 比较，更新跳过位置(规则:最小于接近于初始值的各个序列) ，寻找匹配  ， 更新初始位置（规则:比较各个跳过位置，取最大值）
5. 重复4

Lucene 自然会对这个 block 再次进行压缩。其压缩方式叫做 `Frame Of Reference` 编码 _`Frame Of Reference？？？？是个啥`_

### 加载
如何利用索引和主存储，是一种两难的选择。

* 选择不使用索引，只使用主存储：除非查询的字段就是主存储的排序字段，否则就需要顺序扫描整个主存储。
* 选择使用索引，然后用找到的 row id 去主存储加载数据：这样会导致很多碎片化的随机读操作。

没有所谓完美的解决方案。MySQL 支持索引，一般索引检索出来的行数也就是在 1~100 条之间。`如果索引检索出来很多行，很有可能 MySQL 会选择不使用索引而直接扫描主存储`，`这就是因为用 row id 去主存储里读取行的内容是碎片化的随机读操作，这在普通磁盘上很慢。`

`Opentsdb` 是另外一个极端，`它完全没有索引，只有主存储`。使用 Opentsdb 可以按照主存储的排序顺序快速地扫描很多条记录。但是访问的不是按主存储的排序顺序仍然要面对随机读的问题。

Elasticsearch/Lucene 的解决办法是让主存储的随机读操作变得很快，从而可以充分利用索引，而不用惧怕从主存储里随机读加载几百万行带来的代价。

#### Opentsdb 的弱点
Opentsdb 没有索引，主存储是 `Hbase`。所有的数据点按照时间顺序排列存储在 Hbase 中。Hbase 是一种支持排序的存储引擎，其排序的方式是根据每个 row 的 rowkey（就是关系数据库里的主键的概念）。MySQL 存储时间序列的最佳实践是利用 MySQL 的 Innodb 的 clustered index 特性，使用它去模仿类似 Hbase 按 rowkey 排序的效果。所以 Opentsdb 的弱点也基本适用于 MySQL。

#### DocValues 为什么快？
DocValues 是一种按列组织的存储格式

按列存储的话会把一个文件分成多个文件，每个列一个。对于每个文件，都是按照 docid 排序的。这样一来，只要知道 docid，就可以计算出这个 docid 在这个文件里的偏移量。也就是对于每个 docid 需要一次随机读操作。

那么这种排列是如何让随机读更快的呢？秘密在于 Lucene 底层读取文件的方式是基于 memory mapped byte buffer 的，也就是 mmap。这种文件访问的方式是由操作系统去缓存这个文件到内存里。这样在内存足够的情况下，访问文件就相当于访问内存。那么随机读操作也就不再是磁盘操作了，而是对内存的随机读。

那么为什么按行存储不能用 mmap 的方式呢？因为按行存储的方式一个文件里包含了很多列的数据，这个文件尺寸往往很大，超过了操作系统的文件缓存的大小。而按列存储的方式把不同列分成了很多文件，`可以只缓存用到的那些列`，而不让很少使用的列数据浪费内存。

![avatar](https://static001.infoq.cn/resource/image/aa/a5/aab78e64a7ec5c36fe347991110ed6a5.jpg)
### 分布式计算
#### 分布式聚合如何做得快
Elasticsearch/Lucene 从最底层就支持数据分片，查询的时候可以自动把不同分片的查询结果合并起来。

Elasticsearch 的 document 都有一个 uid，`默认策略是按照 uid 的 hash 把文档进行分片`。
对于聚合查询，其处理是分两阶段完成的：

* Shard 本地的 Lucene Index 并行计算出局部的聚合结果；
* 收到所有的 Shard 的局部聚合结果，聚合出最终的聚合结果。

这种两阶段聚合的架构使得每个 shard 不用把原数据返回，而只用返回数据量小得多的聚合结果

除此之外 Elasticsearch 还有另外一个减少聚合过程中网络传输量的优化，那就是 `Hyperloglog` 算法，Hyperloglog 算法`以一定的误差做为代价`，可以用很小的数据量保存这个 set，从而减少网络传输消耗。

`这里有些解释 关于降维聚合不懂，大概讲的是查询一个时间的 最大的数的和，先做聚合 再降维，以后再看`
### 第五篇 Protobuf 有没有比 JSON 快 5 倍？
这个比较了一下 protobuf 和JSON  编解码性能问题 
大致就是 long double 整形 protobuf 要快78倍，String字符串 或者 整数列表的话性能差不多。
还有一些存储细节 char[] byte[]。

Elasticsearch 将要发布的 2.0 版本的最重量级的新特性是 Pipeline Aggregation，它支持数据在聚合之后再做聚合。类似 SQL 的子查询和 Having 等功能都将被支持。


## 面试相关
###  ES是如何分片的
  ES的路由机制是通过`哈希算法`，将具有相同哈希值的文档放在同一分片中，通过这个哈希算法做负载均衡
```aidl
  计算公式:
`shard = hash(routing) % number_of_primary_shards`　
routing 值是一个任意字符串，它默认是_id但也可以自定义。这个routing 字符串通过哈希函数生成一个数字，然后除以主切片的数量得到一个余数(remainder)
```
#### 指定个性化路由
在插入和查询的时候根据业务需要指定分片(可以使多个)，可以减少资源消耗，但是使用不当会造成文档分布不均匀，某些分片较大







## 参考

[高效管理 Elasticsearch 中基于时间的索引](https://juejin.cn/post/6844903569015963656#comment)
[高效管理 Elasticsearch 中基于时间的索引 english](https://www.elastic.co/cn/blog/managing-time-based-indices-efficiently)