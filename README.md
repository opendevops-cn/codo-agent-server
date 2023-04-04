# codo-agent-server
暂时只开放二进制文件，star 过万再开源

```
WS-PORT: 9999
PORT: 8080
BIND-ADDRESS: 0.0.0.0
AMQP-URI: amqp://admin:123456@127.0.0.1:5672/
ROOT-PATH: /opt/codo/agent-server
LOG-LEVEL: DEBUG
DB-CONFIG:
  DB-TYPE: mysql
  DB-USER: root
  DB-PASSWORD: root@123456
  DB-HOST: 127.0.0.1
  DB-NAME: codo_agent_server
  DB-TABLE-PREFIX: codo_
  DB-FILE: ""
  DB-PORT: 3306
REDIS:
  R-ADDRESS: 127.0.0.1:6379
  R-PASSWORD: "1111"
  R-DB: 1
PUBLISH:
  P-ADDRESS: 127.0.0.1:6379
  P-PASSWORD: "1111"
  P-DB: 1
  P-ENABLE: false

```
## 初始化
```
create database `codo_agent_server` default character set utf8mb4 collate utf8mb4_unicode_ci;
codo-agent-server migrate  
```

## 启动
```
codo-agent-server   --config-file=config.yaml

codo-agent --url ws://127.0.0.1:9999/api/v1/codo/agent?clientId=codo-test -s --log-dir /data/logs/codo --row-limit 2000 --client-type normal
```