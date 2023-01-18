---
title:
---
# AOP （Aspect Oriented Programming）
## AOP应用范围
- Authentication：权限；
- ● Caching：缓存；
- ● Context passing：内容传递；
- ● Error handling：错误处理；
- ● Lazy loading：懒加载；
- ● Debugging：调试；
- ● logging, tracing, profiling and monitoring：记录跟踪、优化、校准；
- ● Performance optimization：性能优化；
- ● Persistence：持久化；
- ● Resource pooling：资源池；
- ● Synchronization：同步；
- ● Transactions：事务。
## AOP名词解释

● 关注点（Concern）：一个关注点就是一个特定的目的，一块我们感兴趣的区域。从技术的角度来说，一个典型的软件系统包含一些核心的关注点和系统级的关注点。举个例子来说，一个信用卡处理系统的核心关注点是借贷/存入处理，而系统级的关注点则是日志、事务完整性、授权、安全及性能问题等。许多关注点——我们叫它横切关注点（Crosscutting Concerns）——会在多个模块中出现，使用现有的编程方法，横切关注点会横越多个模块，结果是使系统难以设计、理解、实现和演进；● 切面（Aspect）：如果一个关注点模块化，则这个关注点可能会横切多个对象。事务管理是Java EE应用中一个关于横切关注点的很好的例子。在Spring AOP中，切面可以使用通用类（基于模式的风格）或者在普通类中以@Aspect注解（@AspectJ风格）来实现；
● 连接点（Joinpoint）：在程序执行过程中的某个特定的点，比如在某方法调用的时候或者处理异常的时候。在Spring AOP中，一个连接点总是代表一个方法的执行。通过声明一个org.aspectj.lang.JoinPoint类型的参数可以使通知（Advice）的主体部分获得连接点信息；
● 通知（Advice）：在切面的某个特定的连接点上执行的动作。通知有各种类型，其中包括“around”、“before”和“after”等。通知的类型将在后面部分进行讨论。许多AOP框架，包括Spring，都以拦截器做通知模型，并维护一个以连接点为中心的拦截器链；
● 切入点（Pointcut）：匹配连接点的断连。通知和一个切入点表达式关联，并在满足这个切入点的连接点上运行（例如，当执行某个特定名称的方法时）。切入点表达式及如何与连接点匹配是AOP的核心，Spring默认使用AspectJ切入点语法；
● 引入（Introduction）：也被称为内部类型声明（Inter Type Declaration），用来声明额外的方法或者某个类型的字段。Spring允许引入新的接口（及一个对应的实现）到任何被代理的对象。例如，你可以使用一个引入来使bean实现IsModified接口，以便简化缓存机制；
● 目标对象（Target Object）：被一个或者多个切面（Aspect）所通知（Advise）的对象。也有人把它叫做被通知（Advised）对象。既然Spring AOP是通过在运行时代理实现的，那么这个对象永远是一个被代理（Proxied）对象；
● AOP代理（AOP Proxy）：AOP框架创建的对象，用来实现切面契约（AspectContract，包括通知方法执行等功能）。在Spring中，AOP代理可以是JDK动态代理或者CGLIB代理；
```
 注意：Spring 2.0最新引入了基于模式（Schema Based）风格和@AspectJ注解风格的切面声明，对于使用这些风格的用户来说，代理的创建是透明的。
```
● 织入（Weaving）：把切面（Aspect）连接到其他的应用程序类型或者对象上，并创建一个被通知（Advised）的对象。这些可以在编译时（例如使用AspectJ编译器），类加载时和运行时完成。Spring和其他纯Java AOP框架一样，在运行时完成织入。

## AOP通知类型
● 前置通知（Before Advice）：在某连接点（Join Point）之前执行的通知，但这个通知不能阻止连接点前的执行（除非它抛出一个异常）；
● 返回后通知（After Returning Advice）：在某连接点（Join Point）正常完成后执行的通知。例如，一个方法没有抛出任何异常，正常返回；
● 抛出异常后通知（After Throwing Advice）：在方法抛出异常，退出时执行的通知；
● 后通知（After Finally Advice）：当某连接点退出的时候执行的通知（不论是正常返回还是异常退出）；
● 环绕通知（Around Advice）：包围一个连接点（Join Point）的通知，如方法调用，这是最强大的一种通知类型。环绕通知可以在方法调用前后完成自定义的行为。它也会选择是继续执行连接点，还是直接返回它们自己的返回值或通过抛出异常来结束执行。