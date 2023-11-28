# codo-agent-server
暂时只开放二进制文件，star 过万再开源

## 服务端配置文件  `config.yaml`
切记只有WS端口可以对外
```
PORT: 8080
WS-PORT: 9999
PPROF-PORT: 9995
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
codo-agent-server --config-file=config.yaml migrate  
```

## 启动 server
```
codo-agent-server   --config-file=config.yaml
```
## 启动 proxy  （可选）
```
codo-agent --url ws://127.0.0.1:9999/api/v1/codo/agent?clientId=8888 -s --log-dir /data/logs/codo  --client-type master
```
## 启动 agent
```
# 直连
codo-agent --url ws://127.0.0.1:9999/api/v1/codo/agent?clientId=codo-test -s --log-dir /data/logs/codo --row-limit 2000 --client-type normal
# 代理
codo-agent --url ws://127.0.0.1:20800/api/v1/codo/agent?clientId=codo-test:8888 -s --log-dir /data/logs/codo --row-limit 2000 --client-type normal
```