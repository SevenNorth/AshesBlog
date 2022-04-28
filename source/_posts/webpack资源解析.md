---
title: webpack资源解析
categories:
  - [webpack]
copyright: true
date: 2022-04-24 07:16:24
tags: [webpack]
---

## 资源解析： 解析ES6与react jsx语法

使用babel-loader。babel的配置文件是：.babelrc

<!-- more -->

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
```js
{
  "presets": [
    "@babel/preset-env"
  ],
  "plugins": [
    "@babel/proposal-class-properties"
  ]
}
```

### 解析react jsx的配置
```js
{
  "presets": [
    "@babel/preset-env",
    "@babel/preset-react", // react的babel preset配置
  ],
  "plugins": [
    "@babel/proposal-class-properties"
  ]
}
```

## 资源解析： 解析css

css-loader用于加载.css文件，并且转换成commonjs对象
style-loader将样式通过`<style>`标签插入到`<head>`中

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
        test: /\.css$/,
        use: [
          'style-loader'
          'css-loader'
        ],
      },
    ],
  },
},
```

## 资源解析： 解析less和sass
less-loader用于将less转换成css
less-loader依赖less

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
        test: /\.css$/,
        use: [
          'style-loader'
          'css-loader'，
          'less-loader'
        ],
      },
    ],
  },
},
```

## 资源解析： 解析图片与字体

file-loader 用于处理文件

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
        test: /\.(png|svg|jpg|gif)$/,
        use: [
          'file-loader'
        ],
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf)$/,
        use: [
          'file-loader'
        ],
      },
    ],
  },
},
```

url-loader 也可以处理图片和字体
可以设置较小资源自动base64

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
        test: /\.(png|svg|jpg|gif)$/,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 10240 // 单位byte
            }
          }
        ],
      },
    ],
  },
},
```