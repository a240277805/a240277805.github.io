---
title:
---
# Servlet
## 生命周期
多线程 单实例
doGet doPost 
Config ,Request ,Response
实例初始化 可以配置 tomcat 启动时<load-on-startup>，也可以在第一次调用时。

### Servlet 3.0新特性
- 引入注解配置 :@WebServlet(name = "myFirstServlet",urlPatterns = {"/aaaa"})
- 支持web模块化开发
- 程序异步处理
- 改进文件上传API
- 非阻塞式IO读取流
- Websocket实时通信


参考:

[Servlet3.0新特性](https://cloud.tencent.com/developer/article/1013528)

|               title | content                                                      |
| ------------------: | ------------------------------------------------------------ |
|     1、工时统计分析 | 项目管理者和部门管理者可基于任务的预估工时及填报工时，了解项目及人员实施表现情况 |
|     2、项目关系调整 | 部门管理员可调整当前项目关系，修改子项目所属父项             |
| 3、审批工时逻辑优化 | 工时审批增加驳回状态展示                                     |
| 4、工时提交流程优化 | 工作台增加一键提交工时操作，缩短体检操作实施路径             |
|     5、工时同步日志 | 审批人可查看审批工时在同步至工时系统时的日志                 |
|         6、其他优化 | 优化bug，提升性能                                            |

