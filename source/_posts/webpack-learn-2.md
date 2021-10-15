---
title: webpack学习记录-2
categories:
  - [FE, webpack]
copyright: true
date: 2021-10-15 15:02:38
tags: 'webpack'
---

# devServer配置
&emsp;&emsp;DevServer： 用来自动化编译、打开浏览器，刷新浏览器，只会在内存中编译打包，不会有文件输出。
<!-- more -->

# 开发环境简单配置

```javascript
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { resolve } = require('path');

module.exports = {
  entry: './src/js/index.js',
  output: {
    filename: 'js/index.js',
    path: resolve(__dirname, 'prod'),
  },
  mode: 'production',
  module: {
    rules: [
      {
        test: /\.less$/,
        use: ['style-loader', 'css-loader', 'less-loader'],
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
      {
        test: /\.(png|gif|jpg)$/,
        loader: 'url-loader',
        options: {
          outputPath: 'img',
          limit: 8 * 1024,
          name: '[hash:10].[ext]',
          esModule: false,
        },
      },
      {
        test: /\.html$/,
        loader: 'html-loader',
        options: {
          esModule: false,
        },
      },
      {
        exclude: /\.(less|css|jpg|png|gif|html|js)$/,
        loader: 'file-loader',
        options: {
          outputPath: 'media',
          name: '[hash:10].[ext]',
        },
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }),
  ],
  devServer: {
    contentBase: resolve(__dirname, 'build'), // 项目构建后的路径
    port: 3000, // 服务端口
    compress: true, // 启用gzip压缩
    open: true, // 自动打开浏览器
  },
};
```

# CSS相关处理
## 提取CSS成单独文件
&emsp;&emsp; 使用插件：`MiniCssExtractPlugin`。
示例代码：
```javascript
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
module.exports = {
  module: {
    rules: [
      {
        test: /\.less$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'less-loader',
        ],
      },
    ],
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: 'css/[chunkhash:10].css', // 对输出的css文件进行重命名
    }),
  ],
}
```
注意： 提取css成单独文件，就不能再用`style-loader`。