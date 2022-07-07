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

-------

## nginx日志配置

Nginx 有一个非常灵活的日志记录模式。每个级别的配置可以有各自独立的访问日志。很多问题可以通过日志排查来进行定位。

### log_format 指令
   log_format指令可以根据自己的需求定义日志格式，即记录访问的时候各个变量的具体的值
- 语法
   ```
   log_format name string …;
   ```
   name 表示格式名称
   string 表示等义的格式。
- 默认值
   ```
   log_format main '$remote_addr - $remote_user [$time_local] '
   ' "$request" $status $body_bytes_sent '
   ' "$http_referer" "$http_user_agent" ';
   ```
- 配置段
   ```
   http
   ```

### access_log 指令

- 语法
   ```
   access_log path [format [buffer=size [flush=time]]];
   access_log path format gzip[=level] [buffer=size] [flush=time];
   access_log syslog:server=address[,parameter=value] [format];
   access_log off;
   ```
   gzip 压缩等级
   buffer 设置内存缓存区大小
   flush 保存在缓存区中的最长时间
- 默认值
   ```
   access_log logs/access.log main;
   ```
- 配置段
   ```
   http, server, location, if in location, limit_except
   ```

### nginx内置变量介绍
- $arg_name

请求中的的参数名，即“?”后面的arg_name=arg_value形式的arg_name

- $args

请求中的参数值

- $binary_remote_addr

客户端地址的二进制形式, 固定长度为4个字节

- $body_bytes_sent

传输给客户端的字节数，响应头不计算在内；这个变量和Apache的mod_log_config模块中的“%B”参数保持兼容

- $bytes_sent

传输给客户端的字节数 (1.3.8, 1.2.5)

- $connection

TCP连接的序列号 (1.3.8, 1.2.5)

- $connection_requests

TCP连接当前的请求数量 (1.3.8, 1.2.5)

- $content_length

“Content-Length” 请求头字段

- $content_type

“Content-Type” 请求头字段

- $cookie_name

Cookie名称

- $document_root

当前请求的文档根目录或别名

- $document_uri

同 $uri

- $host

优先级如下：HTTP请求行的主机名>”HOST”请求头字段>符合请求的服务器名

- $hostname

主机名

- $http_name

匹配任意请求头字段；
变量名中的后半部分“name”可以替换成任意请求头字段，如在配置文件中需要获取http请求头：“Accept-Language”，那么将“－”替换为下划线，大写字母替换为小写，形如：$http_accept_language即可。
- $https

如果开启了SSL安全模式，值为“on”，否则为空字符串。

- $is_args

如果请求中有参数，值为“?”，否则为空字符串。

- $limit_rate

用于设置响应的速度限制，详见 limit_rate。

- $msec

当前的Unix时间戳 (1.3.9, 1.2.6)

- $nginx_version

nginx版本

- $pid

工作进程的PID

- $pipe

如果请求来自管道通信，值为“p”，否则为“.” (1.3.12, 1.2.7)

- $proxy_protocol_addr

获取代理访问服务器的客户端地址，如果是直接访问，该值为空字符串。(1.5.12)

- $query_string

同 $args

- $realpath_root

当前请求的文档根目录或别名的真实路径，会将所有符号连接转换为真实路径。

- $remote_addr

客户端地址

- $remote_port

客户端端口

- $remote_user

用于HTTP基础认证服务的用户名

- $request

代表客户端的请求地址

- $request_body

客户端的请求主体

此变量可在location中使用，将请求主体通过proxy_pass, fastcgi_pass, uwsgi_pass, 和 scgi_pass传递给下一级的代理服务器。

- $request_body_file

将客户端请求主体保存在临时文件中。文件处理结束后，此文件需删除。如果需要之一开启此功能，需要设置client_body_in_file_only。如果将次文件传递给后端的代理服务器，需要禁用request body，即设置proxy_pass_request_body off，fastcgi_pass_request_body off, uwsgi_pass_request_body off, or scgi_pass_request_body off 。

- $request_completion

如果请求成功，值为”OK”，如果请求未完成或者请求不是一个范围请求的最后一部分，则为空。

- $request_filename

当前连接请求的文件路径，由root或alias指令与URI请求生成。

- $request_length

请求的长度 (包括请求的地址, http请求头和请求主体) (1.3.12, 1.2.7)

- $request_method

HTTP请求方法，通常为“GET”或“POST”

- $request_time

处理客户端请求使用的时间 (1.3.9, 1.2.6);
从读取客户端的第一个字节开始计时。
- $request_uri

这个变量等于包含一些客户端请求参数的原始URI，它无法修改，请查看$uri更改或重写URI，不包含主机名，例如：”/cnphp/test.php?arg=freemouse”。

- $scheme

请求使用的Web协议, “http” 或 “https”

- $sent_http_name

可以设置任意http响应头字段；
变量名中的后半部分“name”可以替换成任意响应头字段，如需要设置响应头Content-length，那么将“－”替换为下划线，大写字母替换为小写，形如：$sent_http_content_length 4096即可。
- $server_addr

服务器端地址，需要注意的是：为了避免访问linux系统内核，应将ip地址提前设置在配置文件中。

- $server_name

服务器名，www.cnphp.info

- $server_port

服务器端口

- $server_protocol

服务器的HTTP版本, 通常为 “HTTP/1.0” 或 “HTTP/1.1”

- $status

HTTP响应代码 (1.3.2, 1.2.2)

- $tcpinfo_rtt, $tcpinfo_rttvar, $tcpinfo_snd_cwnd, $tcpinfo_rcv_space

客户端TCP连接的具体信息

- $time_iso8601

服务器时间的ISO 8610格式 (1.3.12, 1.2.7)

- $time_local

服务器时间（LOG Format 格式） (1.3.12, 1.2.7)

- $uri

请求中的当前URI(不带请求参数，参数位于$args)，可以不同于浏览器传递的$request_uri的值，它可以通过内部重定向，或者使用index指令进行修改，$uri不包含主机名，如”/foo/bar.html”。

## 反向代理设置协议头

在使用nginx给Arcgis Server做反向代理的负载均衡的时候，有时候并不会拿到切片或者加载服务。这个时候就需要给代理的location设置相关的协议头。
`proxy_set_header` 即允许重新定义或添加字段传递给代理服务器的请求头。该值可以包含文本、变量和它们的组合。简而言之，`proxy_set_header` 就是可设置请求头-并将头信息传递到服务器端，不属于请求头的参数中也需要传递时，重定义下即可。

```conf
upstream balance {
    server localhost:8080;
    server localhost:8081;
    server localhost:8082;
    server localhost:8083;
}
server {
   listen       80;
   server_name  localhost;
   location / {
      proxy_pass http://balance;
      proxy_redirect off;
      proxy_set_header   Host             $host;
      proxy_set_header   X-Real-IP        $remote_addr;
      proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
      proxy_next_upstream error timeout invalid_header http_500 http_504 http_404;
   }
}
```
简单的解释下：
   - X-Forwarded-For 表示 Nginx 接收到的头，原样的转发过来（假如不转发，Web 服务器就不能获取这个头）。
   - X-Real-IP，这是一个内部协议头（就是反向代理服务器和 Web 服务器约定的），这个头表示连接反向代理服务器的 IP 地址（这个地址不能伪造）。

更多头可以根据后端需要进行配置。如成都CIM项目使用成都时空云的地名地址搜索服务的时候，需要`previewTicket`, 就在代理的时候固定传了一个值。

```conf
location /proxy-geo/ {
   proxy_set_header Referer 'https://www.chengdumap.cn/';
   proxy_set_header previewTicket 'abcdefghijklmnopqrstuvwxyz';
   proxy_set_header Origin 'https://www.chengdumap.cn';
   proxy_set_header Host  'www.chengdumap.cn';
   proxy_pass http://172.34.56.251:90/proxy-geo/;
}
```