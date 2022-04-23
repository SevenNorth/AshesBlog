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

## loader 

webpack 开箱即用支持js和json两种文件类型，通过loaders去支持其他文件类型并且把他们转化成有效的模块，并且可以添加到依赖图中。

loader本身是一个函数，接收源文件作为参数，返回转换后的结果

常见的loaders

| 名称 | 描述 |
| --- | --- |
| babel-loader | 转换ES6、7等JS新特性语法 |
| css-loader | 支持.css文件的加载和解析 |
| less-loader | 将less文件转换成css |
| ts-loader | 将TS转换成JS |
| file-loader | 进行图片、字体等的打包 |
| raw-loader | 将文件以字符的形式导入 |
| thread-loader | 多进程打包JS和CSS |

laoders的用法
```js
const path = require('path');

module.exports = {
  output: {
    filename: 'bundle.js',
  },
  module: {
    rules: [
      {
        test: /\.txt$/, // => test指定规则
        use: 'raw-loader', // => use指定使用的loader名称
      },
    ],
  },
}
```

## plugins

插件用于bundle文件的优化，资源管理和环境变量的注入
作用于整个构建过程
（loaders没办法做的事，可以由plugins完成）

常见的plugins

| 名称 | 描述 |
| --- | --- |
| CommonsChunkPlugin | 将chunks相同的模块代码提取成公共js |
| CleanWebpackPlugin | 清理构建目录 |
| ExtractTextWebpackPlugin | 将css从bundle文件里提取成一个独立的css文件 |
| CopyWebpackPlugin | 将文件或者文件夹拷贝到构建的输出目录 |
| HtmlWebpackPlugin | 创建html文件去承载输出的bundle |
| UglifyjsWebpackPlugin | 压缩js |
| ZipWebpackPlugin | 将打包的资源生成一个zip包 |

plugins使用方法

```js
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin'); // plugin使用前需要先引入
module.exports = {
  output: {
    filename: 'bundle.js',
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }), // =>放到plugins数组里面
  ],
}
```

## mode

Mode用来指定当前的构建环境是： production、development还是none
设置mode可以使用webpack内置的函数，默认值是production。

Mode 的内置函数功能

| 选项 | 描述 |
| --- | --- |
| development | 设置 `process.env.NODE_ENV` 的值为 `development` 。开启 `NameChunkPlugin` 和 `NameModulesPlugin` |
| production | 设置 `process.env.NODE_ENV` 的值为 `production` 。开启 `FlagDependencyUsagePlugin` ， `FlagIncludeChunksPlugin` ，`ModuleContatenationPlugin` ，`NoEmitOnErrorsPlugin` ，`OccurrenceOrderPlugin`， `SideEffectsFlagPlugin` 和 `TerserPlugin`|
| none | 不开启任何优化 |
