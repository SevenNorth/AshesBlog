---
title: webpack学习记录(1)
categories:
  - [FE, webpack]
date: 2021-09-08 20:33:18
tags: 'webpack'
copyright: true
---

# webpack是什么？
 &emsp;&emsp;`webpack` 是一个用于现代JavaScript应用程序的<font color='#f00'>静态打包工具</font>。当webpack处理应用程序的时，会在内部从一个或多个入口点构建一个依赖图，然后将项目中所需要的每一个模块组合成一个或者多个bundles，他们均作为静态资源，用于展示内容。

<!-- more -->

# 核心概念
## 入口起点(entry point)
&emsp;&emsp;入口起点(entry point)指示webpack应该使用哪个模块，来作为构建其内部依赖图(dependency graph)的开始。进入入口起点后，webpack 会找出有哪些模块和库是入口起点（直接和间接）依赖的。

## 输出(output)
&emsp;&emsp;output 属性告诉 webpack 在哪里输出它所创建的 bundle，以及如何命名这些文件。主要输出文件的默认值是 ./dist/main.js，其他生成文件默认放置在 ./dist 文件夹中。

## loader
&emsp;&emsp;webpack 只能理解 JavaScript 和 JSON 文件，这是 webpack 开箱可用的自带能力。loader 让 webpack 能够去处理其他类型的文件，并将它们转换为有效模块，以供应用程序使用，以及被添加到依赖图中。

## 插件(plugin)
&emsp;&emsp;loader 用于转换某些类型的模块，而插件则可以用于执行范围更广的任务。包括：打包优化，资源管理，注入环境变量。

## 模式(mode)
&emsp;&emsp;通过选择 development, production 或 none 之中的一个，来设置 mode 参数，可以启用 webpack 内置在相应环境下的优化。其默认值为 production。

------

# 初步使用

## 打包样式资源
&emsp;&emsp; 使用的loader： `style-loader`、`css-loader`、`less-loader`、`sass-loader` 等。
- `sass-loader`： 将sass(scss)文件编译成css文件,需要配合`node-sass`模块使用。
- `less-loader`： 将less文件编译成css文件，需要配合`less`模块使用。
- `css-loader`： 将css文件变成commonjs模块加载到 js 中，其内容是样式字符串。
- `style-loader`： 创建style标签，将js中的样式资源插入其中，并添加到head标签中，使其生效。

简单配置： 
```javascript
module: {
    rules: [
        {
            test: /\.css$/,
            use: [
                'style-loader',
                'css-loader'
            ]
        },
        {
            test: /\.less$/,
            use: [
                'style-loader',
                'css-loader',
                'less-loader'
            ]
        },
        {
            test: /\.s(a|c)ss/,
            use: [
                'style-loader',
                'css-loader',
                'sass-loader',
            ]
        }
    ]
}
```
注意： use数组中loader的执行顺序，<font color='#f00'>从右到左</font>，<font color='#f00'>从下到上</font> 依次执行。

## 打包html资源
&emsp;&emsp; 使用插件：`html-webpack-plugin`。`html-webpack-plugin` 默认会创建一个空白的html，自动引入打包输出的所有资源（js/css）；也可以指定一个html模板，插件会复制该文件，在其文件中自动引入打包输出的所有资源（js/css）。

简单配置：
```javascript
const HtmlWebpackPlugin = require('html-webpack-plugin');
plugins: [
    new HtmlWebpackPlugin({
        template: './src/index.html'
    })
],
```
注意：插件需要先引入再使用。loader下载即可使用。

## 打包图片资源
&emsp;&emsp; 使用loader： `html-loader`、`url-loader`, `file-loader`。`html-loader`处理html中的img，负责引入img，从而能被`url-loader`处理, `url-loader`依赖于`file-loader`。
&emsp;&emsp; 使用`url-loader`可以将一些小图片转化成base64格式，直接加载到文档中，可以减少一定的请求次数，但也会导致文件体积变大。

简单配置：
```javascript
module: {
    rules: [
        {
            test: /\.(jpg|png|gif|jpeg)$/,
            loader: 'url-loader',
            options: {
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
    ]
}
```
注意： 需要关闭`url-loader`,`html-loader`的es6模块化，使用commonJS。

## 打包其他资源
&emsp;&emsp; 使用`file-loader`打包其他资源。

简单配置：
```javascript
module: {
    rules: [
        // 打包其他资源(除了html/js/css资源以外的资源)
        {
            // 排除css/js/html资源
            exclude: /\.(css|js|html|less)$/,
            loader: 'file-loader',
            options: {
            name: '[hash:10].[ext]',
            },
        },
    ]
}
```