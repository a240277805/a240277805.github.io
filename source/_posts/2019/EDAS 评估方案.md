---
title: 
---
# EDAS 评估方案工作量

## 1d 准备  

1. 准备 provide,consumer 两个Spring cloud demo 项目，准备测试服务调用
2. 准备Springcloud demo 项目，增加正确调用接口
   * 测试调用链
   * 测试服务鉴权
   * 测试限流降级
3. 准备Springcloud demo 项目，增加错误调用接口 测试离群实例摘除策略

## 

###   评估内容  

###　1d部署

1. ECS部署

2. K8s 部署

   

* 配置调度规则
* 配置启动命令
* 配置环境变量
* 配置持久化存储
* 配置本地存储
* 配置应用生命周期的钩子和探针
* 配置日志收集
* 配置Tomcat
* 配置Java启动参数
* 实现Ks集群应用的限流降级

（添加公网SLB实现公网访问）

参考： https://help.aliyun.com/document_detail/158047.html?spm=a2c4g.11186623.6.590.8e627c71tUMU04

## 

###　0.3d 升级和回滚应用

单批发布

分批发布

金丝雀发布

回滚应用

###  0.5d 监控

*　应用总览
*　应用故障自动诊断
*　各种指标监控

###  0.5d 应用运维

* 自动缩扩容
* 发布回滚
* 查看历史版本
* 访问应用(暴露服务)
* 限流降级
* 日志查看
* 事件中心

### 0.2d 服务治理

* 无损下线应用

* 金丝雀发布

  

### 0.1d 服务鉴权

### 应用监控

 参考 https://help.aliyun.com/document_detail/152394.html?spm=a2c4g.11186623.6.648.7cc21f09yOmui9

### 金丝雀发布

参考 https://help.aliyun.com/document_detail/199071.html?spm=a2c4g.11186623.6.855.31d83cc1ZOiAbR

### 0.5d 全链路压测

### 0.2d 链路追踪

### 0.2d 限流降级



## 1d 文档整理输出 

