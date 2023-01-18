---
title:
---
# mysql 缓存
## why
InnoDB作为MySQL的存储引擎，数据是存放在磁盘中的，但如果每次读写数据都需要磁盘IO，效率会很低。为此，InnoDB提供了缓存(Buffer Pool)

## what
mysql缓存机制就是缓存sql 文本及缓存结果，用KV形式保存再服务器内存中

查询缓存不仅将查询语句结构缓存起来，还将查询结果缓存起来


## 参考

* [[玩转MySQL之四]MySQL缓存机制](https://zhuanlan.zhihu.com/p/55947158)
