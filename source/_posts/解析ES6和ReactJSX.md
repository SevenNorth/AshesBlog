---
title: 解析ES6和ReactJSX
categories:
  - [webpack]
copyright: true
date: 2022-04-24 07:16:24
tags: [webpack]
---

<!-- more -->

## 资源解析： 解析ES6

使用babel-loader。babel的配置文件是：.babelrc

```js
const path = require('path');
module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        use: 'babel-loader',
      },
    ],
  },
},
```

### 增加ES6的babel preset配置
```json
{
  "presets": [
    "@babel/preset-env"
  ],
  "plugins": [
    "@babel/proposal-class-properties"
  ]
}
```