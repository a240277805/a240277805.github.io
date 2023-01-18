---
title:
---
# Spring 循环依赖

**【1】 getSingleton(beanName)：源码如下：**

复制

```
//查询缓存
  Object sharedInstance = getSingleton(beanName);
  //缓存中存在并且args是null
  if (sharedInstance != null && args == null) {
       //.......省略部分代码     
       //直接获取Bean实例
   bean = getObjectForBeanInstance(sharedInstance, name, beanName, null);
  }
  
 //getSingleton源码，DefaultSingletonBeanRegistry#getSingleton
protected Object getSingleton(String beanName, boolean allowEarlyReference) {
     //先从一级缓存中获取已经实例化属性赋值完成的Bean
  Object singletonObject = this.singletonObjects.get(beanName);
     //一级缓存不存在，并且Bean正处于创建的过程中
  if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
   synchronized (this.singletonObjects) {
                //从二级缓存中查询，获取Bean的早期引用，实例化完成但是未赋值完成的Bean
    singletonObject = this.earlySingletonObjects.get(beanName);
                //二级缓存中不存在，并且允许创建早期引用（二级缓存中添加）
    if (singletonObject == null && allowEarlyReference) {
                    //从三级缓存中查询，实例化完成，属性未装配完成
     ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
     if (singletonFactory != null) {
      singletonObject = singletonFactory.getObject();
                         //二级缓存中添加
      this.earlySingletonObjects.put(beanName, singletonObject);
                        //从三级缓存中移除
      this.singletonFactories.remove(beanName);
     }
    }
   }
  }
  return singletonObject;
 }
```

- 从源码可以得知，doGetBean最初是查询缓存，一二三级缓存全部查询，如果三级缓存存在则将Bean早期引用存放在二级缓存中并移除三级缓存。（升级为二级缓存）

**【2】addSingletonFactory：源码如下**

复制

```
//中间省略部分代码。。。。。
  //创建Bean的源码，在AbstractAutowireCapableBeanFactory#doCreateBean方法中
  if (instanceWrapper == null) {
            //实例化Bean
   instanceWrapper = createBeanInstance(beanName, mbd, args);
  }
  //允许提前暴露
  if (earlySingletonExposure) {
            //添加到三级缓存中
   addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
  }
  try {
            //属性装配，属性赋值的时候，如果有发现属性引用了另外一个Bean，则调用getBean方法
   populateBean(beanName, mbd, instanceWrapper);
            //初始化Bean，调用init-method，afterproperties方法等操作
   exposedObject = initializeBean(beanName, exposedObject, mbd);
  }
  }

//添加到三级缓存的源码，在DefaultSingletonBeanRegistry#addSingletonFactory
protected void addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) {
  synchronized (this.singletonObjects) {
            //一级缓存中不存在
   if (!this.singletonObjects.containsKey(beanName)) {
                //放入三级缓存
    this.singletonFactories.put(beanName, singletonFactory);
                //从二级缓存中移除，
    this.earlySingletonObjects.remove(beanName);
    this.registeredSingletons.add(beanName);
   }
  }
 }
```

- 从源码得知，Bean在实例化完成之后会直接将未装配的Bean工厂存放在**「三级缓存」**中，并且**「移除二级缓存」**

**【3】addSingleton：源码如下：**

复制

```
//获取单例对象的方法，DefaultSingletonBeanRegistry#getSingleton
//调用createBean实例化Bean
singletonObject = singletonFactory.getObject();

//。。。。中间省略部分代码 

//doCreateBean之后才调用，实例化，属性赋值完成的Bean装入一级缓存，可以直接使用的Bean
addSingleton(beanName, singletonObject);

//addSingleton源码，在DefaultSingletonBeanRegistry#addSingleton方法中
protected void addSingleton(String beanName, Object singletonObject) {
  synchronized (this.singletonObjects) {
            //一级缓存中添加
   this.singletonObjects.put(beanName, singletonObject);
            //移除三级缓存
   this.singletonFactories.remove(beanName);
            //移除二级缓存
   this.earlySingletonObjects.remove(beanName);
   this.registeredSingletons.add(beanName);
```



## 参考

# [spring: 我是如何解决循环依赖的？](https://www.cnblogs.com/wjxzs/p/14239052.html)

[Spring如何解决循环依赖，你真的懂了？](https://hellojava.com/a/88587.html)