---
title:
---
# minio

## policy 策略

```
mc config host add minio http://minio.dev.ctfo.com zq025JHjgbyQF8MfLYKt XGCLDGDK0fYWBWZE84CUrxHGcnepg42huZH4KVwp --api s3v4

docker run -it  --name minio-client -v /root/application:/application -v /root:/23_root --entrypoint=/bin/sh minio/mc

```

## 命令

mc alias list 查看所有别名

