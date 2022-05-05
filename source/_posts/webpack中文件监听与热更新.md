---
title: webpack中文件监听
tags: [webpack]
categories:
  - [webpack]
copyright: true
date: 2022-04-29 06:45:55
---

## 文件监听

文件监听是在发现源码发生变化时，自动构建出新的输出文件
webpack开启监听模式，有两种方式：
- 启动webpack命令时， 带上 --watch 参数
- 在配置webpack.config.js中设置 watch: true

缺陷： 每次需要手动刷新浏览器

<!-- more -->

### 文件监听的原理分析

轮询判断文件的最后编辑时间是否变化
某个文件发生了变化，并不会立刻告诉监听者，而是先缓存起来，等aggregateTimeout

```js
module.exports = {
  // 默认false, 也就是不开启
  watch: true,
  watchOptions: {
    // 默认为空， 不监听文件夹或者文件，支持正则
    ignored: /node_modules/,
    // 监听到变化发生后会等300ms再去执行，默认300ms
    aggregateTimeout: 300,
    // 判断文件是否发生了变化时通过不停询问系统指定文件有没有变化实现的，默认每秒访问1000次
    poll: 1000
  }
}
```

## 热更新： webpack-dev-server

WDS不刷新浏览器
WDS不输出文件，而是放在内存中
使用HotModuleReplacementPlugin插件
**最近版本的webpack的devServer，不再使用contentBase，改为使用static**

```js
const webpack = require('webpack')

module.exports = {
  // ...
  mode: 'development',
  plugins: [
      new webpack.HotModuleReplacementPlugin(),
  ], 
  devServer: {
      static: './dist', // 最新版webpack使用该配置
      hot: true,
  }
}
```

**原理分析**

Webpack Compile: 将js编译成Bundle
HMR Server: 将热更新文件输出给HMR Runtime
Bundle Server: 提供文件在浏览器的访问
HMR Runtime: 会被注入到浏览器，更新文件的变化。与服务器建立连接，通常是websocket
Bundle.js: 构建输出的文件

