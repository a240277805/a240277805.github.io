---
title:
---

# Logback

## 概念

Logback 构建在三个主要的类上：Logger，Appender 和 Layouts。

`Logger` 类作为 logback-classic 模块的一部分。`Appender` 与 `Layouts` 接口作为 logback-core 的一部分。作为一个通用的模块，logback-core 没有 logger 的概念。

### Logger 上下文

任何日志 API 的优势在于它能够禁止某些日志的输出，但是又不会妨碍另一些日志的输出。通过假定一个日志空间，这个空间包含所有可能的日志语句，这些日志语句根据开发人员设定的标准来进行分类。在 logback-classic 中，分类是 logger 的一部分，每一个 logger 都依附在 `LoggerContext` 上，它负责产生 logger，并且通过一个树状的层级结构来进行管理。

一个 Logger 被当作为一个实体，它们的命名是大小写敏感的，并且遵循一下规则：

> 命名层次结构
>
> 如果一个 logger 的名字加上一个 `.` 作为另一个 logger 名字的前缀，那么该 logger 就是另一个 logger 的祖先。如果一个 logger 与另一个 logger 之间没有其它的 logger ，则该 logger 就是另一个 logger 的父级。

例如：名为 `com.foo` 的 logger 是名为 `com.foo.Bar` 的 logger 的父级。名为 `java` 的 logger 是名为 `java.util` 的父级，是名为 `java.util.Vector` 的祖先。

`root logger 作为 logger 层次结构的最高层。`它是一个特殊的 logger，因为它是每一个层次结构的一部分。每一个 logger 都可以通过它的名字去获取。例：

```
Logger rootLogger = LoggerFactory.getLogger(org.slf4j.Logger.ROOT_LOGGER_NAME)
```



### 有效等级又称为等级继承

Logger 能够被分成不同的等级。不同的等级（TRACE, DEBUG, INFO, WARN, ERROR）定义在 `ch.qos.logback.classic.Level` 类中。在 logback 中，类 `Level` 使用 final 修饰的，所以它不能用来被继承。一种更灵活的方式是使用 `Marker` 对象。

如果一个给定的 logger 没有指定一个层级，那么它就会继承离它最近的一个祖先的层级。更正式的说法是：

> 对于一个给定的名为 *L* 的 logger，它的有效层级为从自身一直回溯到 root logger，直到找到第一个不为空的层级作为自己的层级。

为了确保所有的 logger 都有一个层级，root logger 会有一个默认层级 --- DEBUG

以下四个例子指定不同的层级，以及根据继承规则得到的最终有效层级

### 底层实现初探

在介绍了基本的 logback 组件之后，我们准备介绍一下，当用户调用日志的打印方法时，logback 所执行的步骤。现在我们来分析一下当用户通过一个名为 *com.wombat* 的 logger 调用了 **info()** 方法时，logback 执行了哪些步骤。

**第一步：获取过滤器链**

如果存在，则 **TurboFilter** 过滤器会被调用，Turbo 过滤器会设置一个上下文的阀值，或者根据每一条相关的日志请求信息，例如：**Marker**, **Level**， **Logger**， 消息，**Throwable ** 来过滤某些事件。如果过滤器链的响应是 *FilterReply.DENY*，那么这条日志请求将会被丢弃。如果是 *FilterReply.NEUTRAL*，则会继续执行下一步，例如：第二步。如果响应是 *FilterRerply.ACCEPT*，则会直接跳到第三步。

**第二步：应用[基本选择规则](https://github.com/YLongo/logback-chinese-manual/blob/0197a2d5a3820d9c1756c680c2e21e934904c6a6/02第二章：架构.md#方法打印以及基本选择规则)**

在这步，logback 会比较有效级别与日志请求的级别，如果日志请求被禁止，那么 logback 将会丢弃调这条日志请求，并不会再做进一步的处理，否则的话，则进行下一步的处理。

**第三步：创建一个 LoggingEvent 对象 **

如果日志请求通过了之前的过滤器，logback 将会创建一个 ch.qos.logback.classic.LoggingEvent 对象，这个对象包含了日志请求所有相关的参数，请求的 logger，日志请求的级别，日志信息，与日志一同传递的异常信息，当前时间，当前线程，以及当前类的各种信息和 MDC。MDC 将会在后续章节进行讨论。

**第四步：调用 appender**

在创建了 LoggingEvent 对象之后，logback 会调用所有可用 appender 的 doAppend() 方法。这些 appender 继承自 logger 上下文。

所有的 appender 都继承了 AppenderBase 这个抽象类，并实现了 doAppend() 这个方法，该方法是线程安全的。AppenderBase 的 doAppend() 也会调用附加到 appender 上的自定义过滤器。自定义过滤器能动态的动态的添加到 appender 上，在过滤器章节会详细讨论。

**第五步：格式化输出**

被调用的 appender 负责格式化日志时间。但是，有些 appender 将格式化日志事件的任务委托给 layout。layout 格式化 LoggingEvent 实例并返回一个字符串。对于其它的一些 appender，例如 SocketAppender，并不会把日志事件转变为一个字符串，而是进行序列化，因为，它们就不需要一个 layout。

**第六步：发送 LoggingEvent**

当日志事件被完全格式化之后将会通过每个 appender 发送到具体的目的地。

下图是 logback 执行步骤的 UML 图：

[![点击查看大图](https://github.com/YLongo/logback-chinese-manual/raw/0197a2d5a3820d9c1756c680c2e21e934904c6a6/images/underTheHoodSequence2.gif)](https://github.com/YLongo/logback-chinese-manual/blob/0197a2d5a3820d9c1756c680c2e21e934904c6a6/images/underTheHoodSequence2.gif)


## 问题
### root  和 logger 优先级



### 为什么阿里巴巴禁止工程师直接使用日志系统(Log4j、Logback)中的 API

门面模式


### 为何root配置的INFO，logger特殊指定的包/类日志DEBUG级别，最后也能打印出来？

因为没有设置addtivity="false" ，如下图即可。

```shell
1 <logger name="包名/类名" level="DEBUG" addtivity="false" />
```

logger有一个配置addtivity="true" 默认就是true,标识向上级传递日志（INFO是DEBUG的上级）。只有显示指定为false时，才不会向上级输出。

## 参考

# [为什么阿里巴巴禁止工程师直接使用日志系统(Log4j、Logback)中的 API](https://www.hollischuang.com/archives/3000)