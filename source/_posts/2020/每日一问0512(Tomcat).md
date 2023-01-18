---
title:
---
# Tomcat 

## 基于http 协议的服务器
- Apche
- IIS 
- Nginx
- Tomcat 
- JBoss
## 特性
connect container 
一个containner 可以对应多个connector
多线程模型，

NIO
## 基础
### 加载顺序：

1.$java_home/lib 目录下的java核心api 

2.$java_home/lib/ext 目录下的java扩展jar包

3.java -classpath/-Djava.class.path所指的目录下的类与jar包

4.$CATALINA_HOME/common目录下按照文件夹的顺序从上往下依次加载

5.$CATALINA_HOME/server目录下按照文件夹的顺序从上往下依次加载

6.$CATALINA_BASE/shared目录下按照文件夹的顺序从上往下依次加载

7.我们的项目路径/WEB-INF/classes下的class文件

8.我们的项目路径/WEB-INF/lib下的jar文件