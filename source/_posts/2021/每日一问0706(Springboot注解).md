---
title:
---
# Springboot 注解

| 注解                     | 作用概述 | 作用                                                         | 使用方式 | 参考 |
| ------------------------ | -------- | ------------------------------------------------------------ | -------- | ---- |
| @EnableAutoConfiguration | 自动装配 |                                                              |          |      |
| @import                  |          | @Import注解是用来导入配置类或者一些需要前置加载的类.         |          |      |
| @ComponentScan           |          | `扫描被`@Component` (`@Service`,`@Controller`)注解的 bean，注解默认会扫描启动类所在的包下所有的类 ，可以自定义不扫描某些 bean。如下图所示，容器中将排除`TypeExcludeFilter`和`AutoConfigurationExcludeFilter`。 |          |      |

## 参考

https://mp.weixin.qq.com/s/IbV0dTmZBQuQvjD5B4AQFA