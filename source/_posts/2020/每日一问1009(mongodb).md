---
title:
---
# mongodb 

## 命令
* show collections 查看集合
* db.dbName.find({"a":"b"}) 查找
* 创建/切换仓库: use DATABASE_NAME
* 查看当前仓库: db
* 查看所有仓库: show dbs
* 普通库增加用户: (1)use  dbName (2) db.createUser({"user":"ctfo","pwd":"pipelineCTFO!2020",roles:["dbOwner"]})
* 查看用户: show users   ;     db.dbName.users.find().pretty()


