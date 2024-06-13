# Stage 1: 构建阶段
#FROM golang:1.20 AS builder
#
#WORKDIR /src
#ENV GO111MODULE=on
#ENV GOPROXY="https://goproxy.cn,direct"
#COPY ./go.mod /src
#COPY ./go.sum /src
#RUN go mod download
#COPY . /src
#RUN make build

# Stage 2: 运行阶段
FROM rockylinux:9.1

MAINTAINER "shenshuo<191715030@qq.com>"
# 设置编码
ENV LANG C.UTF-8

# 同步时间
ENV TZ=Asia/Shanghai

WORKDIR /data
# 拷贝代码
COPY codo-agent-server .
# 用来拷贝配置文件
COPY conf.yaml .

RUN chmod +x codo-agent-server

EXPOSE 8080 8081 8082 8083

CMD ./codo-agent-server --config-file=conf.yaml
