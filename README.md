# codo-agent-server
暂时只开放二进制文件，star 过万再开源

## 参考文档
- [安装文档](./安装文档.md)
- [更新日志](./更新日志.md)


## 服务端配置文件  `conf.yaml`
切记只有WS端口可以对外
```
PORT: 8080
WS-PORT: 8081
RPC-PORT: 8082
PROM-PORT: 8083
BIND-ADDRESS: 0.0.0.0
# 新版配置
MQCONFIG:
  ENABLED: true
  SCHEMA: "amqp"
  HOST: "127.0.0.1"
  PORT: 5672
  USERNAME: "admin"
  PASSWORD: "123456"
  VHOST: "codo"
ROOT-PATH: E:\go\src\agent-server
LOG-LEVEL: DEBUG
DB-CONFIG:
  DB-TYPE: mysql
  DB-USER: root
  DB-PASSWORD: 123456
  DB-HOST: 127.0.0.1
  DB-NAME: codo_agent_server
  DB-TABLE-PREFIX: codo_
  DB-FILE: ""
  DB-PORT: 3306
REDIS:
  R-HOST: 127.0.0.1
  R-PORT: 6379
  R-PASSWORD: ""
  R-DB: 1
PUBLISH:
  P-HOST: 127.0.0.1
  P-PORT: 6379
  P-PASSWORD: ""
  P-DB: 1
  P-ENABLED: true


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