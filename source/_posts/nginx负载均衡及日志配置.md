---
title: nginx负载均衡及日志配置
tags: [nginx]
categories:
  - [nginx]
copyright: true
date: 2022-07-05 06:25:06
---
## nginx负载均衡

### 什么是负载均衡

负载均衡（Load Balance），它在网络现有结构之上可以提供一种廉价、有效、透明的方法来扩展网络设备和服务器的带宽，并可以在一定程度上增加吞吐量、加强网络数据处理能力、提高网络的灵活性和可用性等。用官网的话说，它充当着网络流中“交通指挥官”的角色，“站在”服务器前处理所有服务器端和客户端之间的请求，从而最大程度地提高响应速率和容量利用率，同时确保任何服务器都没有超负荷工作。如果单个服务器出现故障，负载均衡的方法会将流量重定向到其余的集群服务器，以保证服务的稳定性。当新的服务器添加到服务器组后，也可通过负载均衡的方法使其开始自动处理客户端发来的请求。（详情可参考：[What Is Load Balancing?](https://www.nginx.com/resources/glossary/load-balancing/)）
简言之，负载均衡实际上就是将大量请求进行分布式处理的策略。

<!-- more -->

### 什么是 Nginx 负载均衡

#### 正向代理

正向代理最大的特点是，客户端非常明确要访问的服务器地址，它代理客户端，替客户端发出请求。比如：科学上网，指向具体静态资源。

![20220630202026](http://sevennorth.lovinghlx.cn/imgbed/20220630202026.png)

假设客户端想要访问 Google，它明确知道待访问的服务器地址是 https://www.google.com/，但由于条件限制，它找来了一个能够访问到 Google 的”朋友”：代理服务器。客户端把请求发给代理服务器，由代理服务器代替它请求 Google，最终再将响应返回给客户端。这便是一次正向代理的过程，该过程中服务器并不知道真正发出请求的是谁。

正向代理，服务器端无感知，因为服务器始终只和代理服务器通信，并不知道代理服务器还会向其他端转发信息

#### 反向代理

反向代理隐藏了服务器的信息，它代理的是服务器端，代其接收请求。来自不同客户端的所有请求实际上都发到了代理服务器处，再由代理服务器按照一定的规则将请求分发给各个服务器。反向代理的过程中，客户端并不知道具体是哪台服务器处理了自己的请求。如此一来，既提高了访问速度，又为安全性提供了保证。

![20220630202345](http://sevennorth.lovinghlx.cn/imgbed/20220630202345.png)

反向代理需要考虑的问题是，如何进行均衡分工，控制流量，避免出现局部节点负载过大的问题。通俗的讲，就是如何为每台服务器合理的分配请求，使其整体具有更高的工作效率和资源利用率。

反向代理，客户端无感知，因为客户端始终只和代理服务器通信，并不知道代理服务器还会将请求转发到其他的服务器。

### 负载均衡常用算法
**1. 轮询**
   轮询为负载均衡中较为基础也较为简单的算法，它不需要配置额外参数。假设配置文件中共有 $M$ 台服务器，该算法遍历服务器节点列表，并按节点次序每轮选择一台服务器处理请求。当所有节点均被调用过一次后，该算法将从第一个节点开始重新一轮遍历。

   **特点**：由于该算法中每个请求按时间顺序逐一分配到不同的服务器处理，因此适用于服务器性能相近的集群情况，其中每个服务器承载相同的负载。但对于服务器性能不同的集群而言，该算法容易引发资源分配不合理等问题。

**2. 加权轮询**
   在加权轮询中，每个服务器会有各自的 `weight`。一般情况下，`weight` 的值越大意味着该服务器的性能越好，可以承载更多的请求。该算法中，客户端的请求按权值比例分配，当一个请求到达时，优先为其分配权值最大的服务器。

   **特点**：加权轮询可以应用于服务器性能不等的集群中，使资源分配更加合理化

   Nginx 加权轮询源码可见：[ngx_http_upstream_round_robin.c](https://github.com/nginx/nginx/blob/master/src/http/ngx_http_upstream_round_robin.c)，源码分析可参考：[关于轮询策略原理的自我理解](https://blog.csdn.net/BlacksunAcheron/article/details/84439302)。其核心思想是，遍历各服务器节点，并计算节点权值，计算规则为 `current_weight` 与其对应的 `effective_weight` 之和，每轮遍历中选出权值最大的节点作为最优服务器节点。其中 `effective_weight` 会在算法的执行过程中随资源情况和响应情况而改变。

**3. IP 哈希（IP hash）**
   `ip_hash` 依据发出请求的客户端 IP 的 hash 值来分配服务器，该算法可以保证同 IP 发出的请求映射到同一服务器，或者具有相同 hash 值的不同 IP 映射到同一服务器。

   **特点**：该算法在一定程度上解决了集群部署环境下 Session 不共享的问题。
   >Session 不共享问题是说，假设用户已经登录过，此时发出的请求被分配到了 A 服务器，但 A 服务器突然宕机，用户的请求则会被转发到 B 服务器。但由于 Session 不共享，B 无法直接读取用户的登录信息来继续执行其他操作。

   实际应用中，可以利用 `ip_hash`，将一部分 IP 下的请求转发到运行新版本服务的服务器，另一部分转发到旧版本服务器上，实现灰度发布。再者，如遇到文件过大导致请求超时的情况，也可以利用 `ip_hash` 进行文件的分片上传，它可以保证同客户端发出的文件切片转发到同一服务器，利于其接收切片以及后续的文件合并操作。

**4. 其他算法**
   - URL hash
    `url_hash` 是根据请求的 URL 的 hash 值来分配服务器。该算法的特点是，相同 URL 的请求会分配给固定的服务器，当存在缓存的时候，效率一般较高。然而 Nginx 默认不支持这种负载均衡算法，需要依赖第三方库。

### 基于Nginx的负载均衡应用
   一台笔记本 + Nginx + Node 测试负载均衡。通过笔记本多个不同端口模拟不同的服务器。
#### 基于 Node + Express 框架来搭建简单的服务器
新建js文件， 并写入代码
```js
const express = require('express');
const app = express();

// 定义要监听的端口号
const listenedPort = '8080';

app.get('/', (req, res) => res.send(`Hello World! I am port ${listenedPort}～`));

// 监听端口
app.listen(listenedPort, () => console.log(`success: ${listenedPort}`));
```
可以多起几个服务，监听不同的端口，每个端口send不同的文案以区分不同的server；

这是我的目录结构
![20220630215026](http://sevennorth.lovinghlx.cn/imgbed/20220630215026.png)
开启4个服务
![20220630215144](http://sevennorth.lovinghlx.cn/imgbed/20220630215144.png)

#### 在 `nginx.conf` 文件中配置好需要轮询的服务器和代理

- 轮询的服务器，写在http块中的upstream：
```conf
# balance 名称可以自己任意
upstream balance {
    server localhost:8080;
    server localhost:8081;
    server localhost:8082;
    server localhost:8083;
}
```
- 代理地址，写在http块中的server块里：
```conf
location / {
    root   html;
    index  index.html index.htm;
    proxy_pass http://balance; # balance 为自己定义的服务器集群
}  
```

#### 启动nginx，查看结果

- 启动nginx：
```bash
start nginx.exe -c /conf/nginx4balance.conf
```
- 打开`http://localhost`进行查看
![balance](http://sevennorth.lovinghlx.cn/imgbed/balance.gif)
通过多次刷新可以发现，同一个端口可以收到不同的server返回的text。

### 负载均衡模式及参数
#### 模式

- 默认轮询
   请求会随机派发到配置的服务器上
```conf
upstream balance {
    server localhost:8080;
    server localhost:8081;
    server localhost:8082;
    server localhost:8083;
}
```

- 哈希分配
   根据客户端IP来分配服务器，比如第一次访问请求被派发给了localhost:8080这台服务器,那么这个客户端之后的请求就都会发送这台服务器上。
```conf
upstream balance {
    ip_hash;
    server localhost:8080;
    server localhost:8081;
    server localhost:8082;
    server localhost:8083;
}
```

- 最少连接分配
   根据添加的服务器判断哪台服务器分的连接最少就把请求给哪台
```conf
upstream balance {
    least_conn;
    server localhost:8080;
    server localhost:8081;
    server localhost:8082;
    server localhost:8083;
}
```

#### 参数
下面的参数可同时配置，使用空格分开即可

| 参数 | 说明 |
| :-: | :-: |
| down | 表示当前的server暂时不参与负载 |
| weight | 默认为1。weight越大，负载的权重就越大。可以根据服务器配置的不同来设置 |
| max_fails |允许请求失败的次数默认为1。当超过最大次数时，返回 `proxy_next_upstream` 模块定义的错误 |
| fail_timeout | max_fails次失败后，暂停的时间 |
| backup | 其它所有的非backup机器down或者忙的时候，请求backup机器。所以这台机器压力会最轻 |
| max_conns | 最大连接数。为防止单机性能过载可以根据实际情况设置 |

示例如下：
```conf
upstream balance {
    server localhost:8080 weight=1;
    server localhost:8081 weight=2;
    server localhost:8082 weight=3;
    server localhost:8083 weight=4 max_fails=10 fail_timeout=60s;
}
```