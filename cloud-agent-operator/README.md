# cloud-agent-operator

云原生的 agent-server 任务执行器

## 快速开始

### 配置 
- configmap 里的 `SERVER-ADDRESS` 参数 指向 agent-server 的地址
- configmap 里的 `BIZ-ID` 参数 配置为对应业务的 ID

### 安装
```shell
kubectl apply -f ./deploy/crd.yaml
kubectl apply -f ./deploy/crd-deploy.yaml
kubectl -n cloud-agent-operator-system apply -f ./deploy/redis.yaml
kubectl -n cloud-agent-operator-system apply -f ./deploy/configmap.yaml
```

## 快速使用
- [必填] taskId 任务ID (唯一)
- [必填] taskType 任务类型 (CloudTask)
- [必填] agentID 用于执行云原生任务的 AgentID
- [必填] taskYaml 脚本的定义, 详情见后面的配置
- [必填] taskYaml 脚本的定义, 详情见后面的配置
- [可选] timeout 超时时间(秒)(默认600秒)
- [可选] scriptParams 脚本使用的参数, 通过环境变量添加 `codo_` 前缀注入( abc 在环境变量中是 $codo_abc)
- [可选] namespace 脚本执行的命名空间, 默认为 default

```shell
curl -X POST {agent-server-http-addr}/api/v1/agent/task/batch \
  -H 'Content-Type: application/json' \
  -d '[
  {
    "taskId": "task123",
    "taskType": "CloudTask",
    "agentId": "agent456",
    "args": {
      "timeout": 60,
      "scriptParams": "{\"abc\": \"1\"}",
      "namespace": "default",
      "taskYaml": "# [必选] 任务定义\ntaskSpec:\n  # [必选] 任务展示名称\n  displayName: \"cc-test\"\n\n  # [必选] 任务步骤定义\n  # 任务有两种模式(只能选其一)\n  # - script 模式:\n  # - command 模式:\n  steps:\n    # [必选] 步骤名称\n    - name: \"step1\"\n      # [可选] 超时时间(默认60分钟)\n      # 持续时间字符串是可能有符号的十进制数字序列，每个十进制数字都带有可选的分数和单位后缀，\n      # 例如“300ms”、“-1.5h”或“2h45m”。有效的时间单位为“ns”、“us”（或“μs”）、“ms”、“s”、“m”、“h”。\n      timeout: \"10s\"\n      # [必选] 任务运行所处的镜像\n      image: \"ccr.ccs.tencentyun.com/library/alpine:latest\"\n      # [必选] 运行的脚本(与 command 二选一)\n      script: |\n        #!/bin/sh\n        echo \"Hello World step1 FOO=$FOO\"\n    - name: \"step2\"\n      image: \"ccr.ccs.tencentyun.com/library/alpine:latest\"\n      # [必选] 指定命令执行(与 script 二选一)\n      command: [ codo ]\n      args: [ \"set-context\", \"abc=123\" ]\n    - name: \"step3\"\n      image: \"ccr.ccs.tencentyun.com/library/alpine:latest\"\n      script: |\n        #!/bin/python\n        import os\n        print(\"Hello World step3 FOO=%s\" % os.environ.get(\"FOO\"))"
    }
  }
]'
```

## [简单任务定义](example.min.yaml)
```yaml
# [必选] 任务定义
taskSpec:
  # [必选] 任务展示名称
  displayName: "cc-test"

  # [必选] 任务步骤定义
  # 任务有两种模式(只能选其一)
  # - script 模式:
  # - command 模式:
  steps:
    # [必选] 步骤名称
    - name: "step1"
      # [可选] 超时时间(默认60分钟)
      # 持续时间字符串是可能有符号的十进制数字序列，每个十进制数字都带有可选的分数和单位后缀，
      # 例如“300ms”、“-1.5h”或“2h45m”。有效的时间单位为“ns”、“us”（或“μs”）、“ms”、“s”、“m”、“h”。
      timeout: "10s"
      # [必选] 任务运行所处的镜像
      image: "ccr.ccs.tencentyun.com/library/alpine:latest"
      # [必选] 运行的脚本(与 command 二选一)
      script: |
        #!/bin/sh
        echo "Hello World step1 FOO=$FOO"
    - name: "step2"
      image: "ccr.ccs.tencentyun.com/library/alpine:latest"
      # [必选] 指定命令执行(与 script 二选一)
      command: [ codo ]
      args: [ "set-context", "abc=123" ]
    - name: "step3"
      image: "ccr.ccs.tencentyun.com/library/alpine:latest"
      script: |
        #!/bin/python
        import os
        print("Hello World step3 FOO=%s" % os.environ.get("FOO"))

```

## [全量任务定义](example.full.yaml)
```yaml
# [可选] pod 的资源限制
# 用户可以选择在任务级指定资源需求，而不是在每个 Step 上指定资源需求。如果用户指定了任务级资源要求，
# 它将确保 kubelet 只为执行 Task 的 Steps 保留该数量的资源。如果用户指定了任务级资源限制，则任何 Step 都不能使用超过该数量的资源。
computeResources:
  requests:
    memory: "128Mi" # 申请 512 MB 的内存
    cpu: "60m" # 申请 1 Core 的 CPU

# [可选] 预计生成的 pod 的要求
podTemplate:
  # [可选] NodeSelector 是一个选择器，它必须为 true 才能使 pod 适合节点。
  # 它必须与要在该节点上调度 pod 的节点标签相匹配。更多信息：https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  nodeSelector: { }
  # [可选] pod 的环境变量
  env: [ ]
  # [可选] 此 Toleration 附加到的 pod 可以容忍使用匹配运算符 <operator> 与三元组 <key,value,effect> 匹配的任何污点。
  tolerations:
    - key: "key"
      operator: "Equal"
      value: "value"
      effect: "NoSchedule"
  # [可选] pod 亲缘性配置
  # 更多信息：https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.io/e2e-az-name
                operator: In
                values:
                  - e2e-az1
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          preference:
            matchExpressions:
              - key: another-node-label-key
                operator: In
                values:
                  - another-node-label-value
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: security
                operator: In
                values:
                  - S1
          topologyKey: failure-domain.beta.kubernetes.io/zone
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: security
                operator: In
                values:
                  - S1
          topologyKey: failure-domain.beta.kubernetes.io/zone

  # [可选] SecurityContext 保存 Pod 级别的安全属性和通用容器设置。默认为空。每个字段的默认值请参阅类型说明。
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
  # [可选] 属于 pod 的容器可以挂载的卷列表。更多信息：https://kubernetes.io/docs/concepts/storage/volumes
  volumes:
    - name: my-cache
      persistentVolumeClaim:
        claimName: my-volume-claim
  # [可选] 设置容器的运行时类名
  # RuntimeClassName 指的是 node.k8s.io 组中的一个 RuntimeClass 对象,
  # 该对象应该用于运行这个 pod。如果没有 RuntimeClass 资源
  # 匹配指定的类名,则该 pod 将不会运行。如果未设置或为空,将
  # 使用"legacy"（遗留）RuntimeClass,这是一个隐式类,其定义为空,
  # 使用默认的运行时处理程序。
  # 更多信息: https://git.k8s.io/enhancements/keps/sig-node/runtime-class.md
  # 这是 Kubernetes v1.14 版本中的一个 beta 特性。
  runtimeClassName: "runc"

  # [可选] AutomountServiceAccountToken 指示以此服务帐户运行的 Pod 是否应自动挂载 API 令牌。可以在 Pod 级别覆盖。
  automountServiceAccountToken: false
  # [可选] Pod 设置 DNS 策略。默认为“ClusterFirst”。有效值为
  # “ClusterFirstWithHostNet”、“ClusterFirst”、“默认”或“无”。
  # DNSConfig 中给出的 DNS 参数将与使用 DNSPolicy 选择的策略合并。
  # 要将 DNS 选项与 hostNetwork 一起设置，您必须将 DNS 策略显式指定为“ClusterFirstWithHostNet”。
  dnsPolicy: ""
  # [可选] 指定 Pod 的 DNS 参数。此处指定的参数将合并到基于 DNSPolicy 生成的 DNS 配置中。
  dnsConfig:
    nameservers: # DNS 名称服务器 IP 地址的列表。这将被附加到从 DNSPolicy 生成的基本名称服务器中。重复的名称服务器将被删除。
      - "8.8.8.8"
    searches: # 用于主机名查找的 DNS 搜索域列表。这将被附加到从 DNSPolicy 生成的基本搜索路径中。重复的搜索路径将被删除。
      - "svc.cluster.local"
    options: # DNS 解析器选项列表。这将与 DNSPolicy 生成的基本选项合并。重复的条目将被删除。选项中给出的解析选项将覆盖基本 DNSPolicy 中出现的解析选项。
      - name: "ndots"
        value: "2"
  # [可选] EnableServiceLinks 指示是否应将有关服务的信息注入到 pod 的环境变量中，与 Docker 链接的语法相匹配。可选：默认为 true。
  enableServiceLinks: true
  # [可选] 设置容器的优先级类名
  # - 如果指定，则指示 Pod 的优先级。 “system-node-key”和“system-cluster-key”是两个特殊的关键字，
  #   表示最高优先级，前者为最高优先级。任何其他名称必须通过创建具有该名称的 PriorityClass 对象来定义。
  # - 如果未指定，Pod 优先级将为默认值；如果没有默认值，则 Pod 优先级为零。
  priorityClassName: ""
  # [可选] 设置容器的调度策略
  schedulerName: "default-scheduler"
  # [可选] ImagePullSecrets 是对同一命名空间中 Secrets 的引用的可选列表，用于拉取此 PodSpec 使用的任何镜像。
  # 如果指定，这些 Secrets 将传递给各个拉取器实现以供他们使用。
  # 更多信息：https://kubernetes.io/docs/concepts/containers/images#specifying-imagepullsecrets-on-a-pod
  imagePullSecrets:
    - name: my-secret # 引用对象名, 参考: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
  # [可选] HostAliases 是一个可选的主机和 IP 列表，如果指定，将被注入到 Pod 的主机文件中。这仅对非 hostNetwork pod 有效。
  hostAliases:
    - ip: ""
      hostnames: [ "" ]
  # [可选] 此 Pod 请求主机网络。使用主机的网络命名空间。如果设置此选项，则必须指定将使用的端口。默认为 false。
  hostNetwork: false
  # [可选] TopologySpreadConstraints 描述一组 Pod 应如何跨拓扑域分布。调度程序将以遵守约束的方式调度 Pod。所有topologySpreadConstraints 都是AND 运算。
  # corev1.TopologySpreadConstraint
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: DoNotSchedule
      labelSelector:
        matchLabels:
          app: myapp
        namespaces:
          - mynamespace


# [可选] 超时时间(默认60分钟)
# 持续时间字符串是可能有符号的十进制数字序列，每个十进制数字都带有可选的分数和单位后缀，
# 例如“300ms”、“-1.5h”或“2h45m”。有效的时间单位为“ns”、“us”（或“μs”）、“ms”、“s”、“m”、“h”。
timeout: "10m"  # 10分钟


# [必选] 任务定义
taskSpec:
  # [必选] 任务展示名称
  displayName: "cc-test"
  # [可选] 描述
  description: "这是一份描述"
  # [可选] 存储定义
  # 除了为输入和输出资源隐式创建的卷之外，指定一个或多个 Volumes ，以便 Task 中的 Steps 执行。
  volumes:
    - name: my-volume
      emptyDir: { }

  # [必选] 任务步骤定义
  # 任务有两种模式(只能选其一)
  # - script 模式:
  # - command 模式:
  steps:
    # [必选] 步骤名称
    - name: "step1"
      # [可选] 超时时间(默认60分钟)
      # 持续时间字符串是可能有符号的十进制数字序列，每个十进制数字都带有可选的分数和单位后缀，
      # 例如“300ms”、“-1.5h”或“2h45m”。有效的时间单位为“ns”、“us”（或“μs”）、“ms”、“s”、“m”、“h”。
      timeout: "10s"
      # [必选] 任务运行所处的镜像
      image: "ccr.ccs.tencentyun.com/library/alpine:latest"
      # [可选] 镜像拉取策略
      # [Always | Never | IfNotPresent]
      # 如果 tag 是 :latest ,则 默认是 Always , 其他情况的 tag , 默认都是 IfNotPresent
      imagePullPolicy: "IfNotPresent"
      # [可选] 指定环境变量, 这里的环境变量是静态的, 会和 codo 的参数进行合并, 如果 key 冲突时, 以 codo 的参数为准
      env:
        - name: "FOO"
          value: "baz"
      # [可选] 指定 step容器 的资源需求
      # 所有 step 的配置必须加起来小于 pod 的配置
      # 这里的配置会在上层被覆盖, key 级别覆盖, 例如上层只指定 memory: 128Mi, 则 cpu 还是按照 500m 来使用
      computeResources:
        requests:
          memory: "256Mi" # 申请 256 MB 的内存
          cpu: "500m" # 申请 0.5 Core 的 CPU
      # [可选] 工作目录
      workingDir: /data
      # [可选] 当 step 出错时的处理方式
      # [ continue | stopAndFail ]
      onError: stopAndFail
      # [可选] securityContext 是 Kubernetes 和 Tekton 中的一个重要配置，用于设置容器的安全上下文。
      # 在 Step 中，securityContext 可以用来控制容器的权限和行为。
      #        securityContext:
      #          runAsUser: 1000
      #          runAsGroup: 3000
      #          fsGroup: 2000
      #          allowPrivilegeEscalation: false
      #          privileged: false
      #          capabilities:
      #            drop:
      #              - ALL
      #          readOnlyRootFilesystem: true
      # [可选] 挂载存储
      volumeMounts:
        - name: my-volume
          mountPath: /data
      # [必选] 运行的脚本(与 command 二选一)
      script: |
        #!/bin/sh
        echo "Hello World step1 FOO=$FOO"
    - name: "step2"
      image: "ccr.ccs.tencentyun.com/library/alpine:latest"
      # [必选] 指定命令执行(与 script 二选一)
      command: [ codo ]
      args: [ "set-context", "abc=123" ]
    - name: "step3"
      image: "ccr.ccs.tencentyun.com/library/alpine:latest"
      script: |
        #!/bin/sh
        echo "context=====$(codo get-context abc)"
    - name: "step4-python-test"
      image: "harbor.123u.com/public/rocky9.1-python3:latest"
      script: |
        #!/bin/python3.9
        from floating import Floating
        # 请手动指定，调用api模式。
        fl = Floating(api_mode=True)
        fl.logger.info("hello world")
```