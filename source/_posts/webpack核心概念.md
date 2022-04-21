---
title: webpack核心概念
categories:
  - [webpack]
copyright: true
date: 2022-04-22 07:26:17
tags: [webpack]
---

## entry

entry用来指定webpack打包入口
单入口：entry是一个字符串。适合SPA，项目中只有一个入口文件的情况；
多入口：entry是一个对象。
```js
// 单入口
module.exports = {
  entry: './path/to/xxx/file.js'
}
// 多入口
module.exports = {
  entry: {
    app: './src/app.js',
    adminiApp: './src/adminApp.js',
  }
}
```


<!-- more -->

## output

output 用来告诉webpack如何将编译后的文件输出到磁盘

单入口配置：
```js
module.exports = {
  entry: './path/to/xxx/file.js',
  output: {
    filename: 'bouundle.js',
    path: __dirname + '/dist' 
  }
}
```

多入口配置：
```js
module.exports = {
  entry: {
    app: './src/app.js',
    search: './src/search.js',
  },
  output: {
    filename: '[name].js',
    path: __dirname + '/dist' 
  }
}
```
通过占位符确保文件名称的唯一性。`name`指定打包出来后的文件的名称。
