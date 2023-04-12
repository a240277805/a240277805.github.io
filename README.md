# 博客系统
## 怎么搭建
## 怎么启动
windows 用 gitbash执行：`hexo server`
然后访问 localhost:4000
## 怎么调试
## 怎么发布

## version 
### 2023/04/11
1. 增加文章加密
        ```
        npm install --save hexo-blog-encrypt
        ```
2. 修改主题
https://redefine-docs.ohevan.com/home
### 2023/04/12
1. 增加视频使用
文章头添加：
```
<script type="text/javascript" src="https://web-1253780623.cos.ap-shanghai.myqcloud.com/zhf-blog/js/ckplayer.js"></script>  
<div class="videosamplex">
<script type="text/javascript" src="https://web-1253780623.cos.ap-shanghai.myqcloud.com/zhf-blog/js/gotoplayer.js"> </script>

```
视频添加: 
```
<div class="videosamplex">  
 <video id="videoplayer"  
  src="../../ImgSource/a.mp4"></video>  
</div>  
<script> 
	gotoplayer("../../ImgSource/a.mp4");
</script>

```
视频路径 ImgSource/