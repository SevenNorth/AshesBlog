---
title: webpack中的文件指纹策略
tags: [webpack]
categories:
  - [webpack]
copyright: true
date: 2022-05-07 06:18:23
---

## 什么是文件指纹？

打包输出的文件名的后缀。可以用来做版本管理。

<!-- more -->

## 文件指纹如何生成？

**hash**：和整个项目的构建相关，只要项目文件有修改，整个项目构建的hash值就会更改
**chunkhash**：和webpack打包的chunk有关，不同的entry会生成不同的chunkhash值
**contenthash**：根据文件内容来定义hash，文件内容不变，则contenthash不变

## JS的文件指纹设置

设置output的filename， 使用[chunkhash]

```js
const path = require('path')

module.exports = {
  entry: {
    app: './src/app.js',
    search: './src/search.js'm
  },
  output: {
    filename: '[name][chunkhash:8].js',
    path: path.resolve(__dirname, 'dist'),
  },
}
```

## CSS的文件指纹设置

设置`MiniCssExtractPlugin`的filename,使用[contenthash]

```js
const path = require('path')

module.exports = {
  entry: {
    app: './src/app.js',
    search: './src/search.js'm
  },
  output: {
    filename: '[name][chunkhash:8].js',
    path: path.resolve(__dirname, 'dist'),
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name][contenthash:8].css'
    })
  ]
}
```

## 图片的文件指纹设置

设置`file-loader`的name， 使用[hash]

```js
const path = require('path')

module.exports = {
  entry: {
    app: './src/app.js',
    search: './src/search.js'm
  },
  output: {
    filename: '[name][chunkhash:8].js',
    path: path.resolve(__dirname, 'dist'),
  },
  module: {
    rules: [
      {
        test: /\.(png|svg|jpg|gif|jpeg)$/,
        use: [{
          loader: 'file-loader',
          options: {
            name: 'img/[name][hash:8].[ext]'
          }
        }]
      }
    ]
  }
}
```

## 占位符名称及含义

| 占位符名称 | 含义 |
| --- | --- |
| [ext] | 资源后缀名 |
| [name] | 文件名称 |
| [path] | 文件相对路径 |
| [folder] | 文件所在文件夹 |
| [contenthash] | 文件的内容的hash，默认是md5生成 |
| [hash] | 文件内容的hash， 默认是md5生成 |
| [emoji] | 一个随机的指定文件内容的emoji |
