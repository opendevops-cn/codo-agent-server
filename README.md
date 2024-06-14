# codo-agent-server
暂时只开放二进制文件，star 过万再开源

## 参考文档
- [Agent安装文档](./安装文档.md)
- [更新日志](./更新日志.md)


## 服务端部署
## 服务端配置文件  `conf.yaml`
切记只有WS端口可以对外
- [服务端配置文件](./conf.yaml)
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