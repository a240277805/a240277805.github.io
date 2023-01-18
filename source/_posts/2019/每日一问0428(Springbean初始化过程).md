---
title:
---
<<<<<<< HEAD
# Spring bean 初始化过程
问题
*  1.bean 是如何被初始化 在 IOC容器中的
* 2.bean 是如何销毁的
* 3.bean 初始化后保存在哪
* 4.bean bean 怎么延迟初始化的
* 5.通过main 方法怎么实现一个 bean

在理解任何技术之前，我都会问自己一个问题：它的产生是为了解决什么样的问题，以及如何解决这些问题？希望你能在本篇文章中找到答案……
### 怎么将自己的对象注入Spring
- @bean
- ApplicationContext.beanFactory.register...
- FactoryBean 注入对象 生成defination 放入 map（BeanDefinationMap里增加自己对象的class）

`classLoader 加载有注解的类 ，生成 define,放入BeanDefinationMap,当用到的时候，从define 查找，拿出来初始化。`

知识点收集：</br>
&nbsp;&nbsp;&nbsp;&nbsp;&#160;上面的生命周期流程图，时候的时候注意调用先后顺序，避免属性被覆盖的现象。
* BeanFactoryPostProcessor 主要是在Spring刚加载完配置文件，还没来得及初始化Bean的时候做一些操作。比如篡改某个Bean在配置文件中配置的内容。
* InstantiationAwareBeanPostProcessorAdapter 基本没什么鸟用，Bean初始化后，还没有设置属性值时调用，和BeanFactoryPostProcessor一样，可以篡改配置文件加载到内存中的信息。 
* ApplicationContextAware:用处很大，注入了ApplicationContext到Bean中。
* InitializingBean:有用处，可以在Bean属性全部改完之后，再做一些定制化操作。
* BeanPostProcessor：没什么用，Spring框架内部使用的比较猛，像什么AOP，动态代理，都是在这搞事。后期有时间和大家分析。
* 其他的像什么init-method，destroy方法，基本都是个摆设。。我是没怎么用过，只知道有这么回事。

**问：?ApplicationContextAware:用处很大，注入了ApplicationContext到Bean中。   ApplicationContext 是啥**

  【Spring】BeanFactory 解析 bean 详解 https://juejin.im/post/5b9f707ce51d450e3f6b8244
    1.XmlBeanFactory 加载 bean  这是初级操作， 在企业开发中一般是使用功能更完善的 ApplicationContext

XmlBeanFactory 的实现 ：
  实现了 DefaultListableBeanFactory 	，他是注册加载bean 的默认实现，是bean加载的核心部分。
  XmlBeanFactory 不同的是 替换了自定义的 xml 读取器

> https://juejin.im/post/593386ca2f301e00584f8036

顺便增加了 对IOC的理解，**就是叫你不用去管对象的生命周期，而关注到对象的使用上**</br>
IOC 常用的有两种方式：
>构造方法注入和setter注入

ApplicationContext 容器 ，可以认为是BeanFactory的一种扩展。
* BeanFactory 默认采用延迟 初始化策略( lazy-load)  ?还有啥初始化策略，
*  BeanDefinition Bean生成 Bean定义的地方  （读取配置 reader 读取 ，property 读取 ，然后生成对象相关的定义，并未真正初始化）
* BeanDefinitionRegistry bean的注册中心 （将对象的定义 注册上）（注册的时候 会生成一个注册码）
*  BeanFactory 可以取到任意定义过的Bean  （对象的出口，有就拿走，没有就生成）

## 对象的初始化
初始是通过 beanFactory的 getBean()时才进行的。

* 对象不是new出来的 其实这里用到了AOP机制，生成了其代理对象，通过 反射机制 生成接口对象，或者是通过CGLIB生成子对象
* beanWrapper 实现了bean 具体装载过程（它继承了PropertyAccessor （可以对属性进行访问）、PropertyEditorRegistry 和TypeConverter接口 （实现类型转换））
* BeanPostprocessor 可以帮助 初始化之前和之后的完成一些必要工作 ，比如 参数解密。
* 在完成postProcessor 之后，则会看对象是否定义了InitializingBean 接口  或者 spring还提供了另外一种指定初始化的方式，即在bean定义中指定init-method 。


## ApplicationContext

ApplicationContext 拥有BeanFactory的所有功能，但应用方法略有不同

* bean的加载方式
* BeanFactory提供BeanReader来从配置文件中读取bean配置。相应的ApplicationContext也提供几个读取配置文件的方式 xxxxxxreader.xml

* ApplicationContext采用的非懒加载方式 	它会在启动阶段完成所有的初始化，并不会等到getBean()才执行。




