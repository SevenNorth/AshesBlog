---
title: webpack学习记录(1)
categories:
  - [FE, webpack]
date: 2021-09-08 20:33:18
tags: 'webpack'
copyright: false
---

# webpack是什么？
 &emsp;&emsp;`webpack` 是一个用于现代JavaScript应用程序的<font color='#f00'>静态打包工具</font>。当webpack处理应用程序的时，会在内部从一个或多个入口点构建一个依赖图，然后将项目中所需要的每一个模块组合成一个或者多个bundles，他们均作为静态资源，用于展示内容。

<!-- more -->

# 核心概念
## 1. 入口起点(entry point)
&emsp;&emsp;入口起点(entry point)指示webpack应该使用哪个模块，来作为构建其内部依赖图(dependency graph)的开始。进入入口起点后，webpack 会找出有哪些模块和库是入口起点（直接和间接）依赖的。

## 2. 输出(output)
&emsp;&emsp;output 属性告诉 webpack 在哪里输出它所创建的 bundle，以及如何命名这些文件。主要输出文件的默认值是 ./dist/main.js，其他生成文件默认放置在 ./dist 文件夹中。

## 3. loader
&emsp;&emsp;webpack 只能理解 JavaScript 和 JSON 文件，这是 webpack 开箱可用的自带能力。loader 让 webpack 能够去处理其他类型的文件，并将它们转换为有效 模块，以供应用程序使用，以及被添加到依赖图中。

## 4. 插件(plugin)
&emsp;&emsp;loader 用于转换某些类型的模块，而插件则可以用于执行范围更广的任务。包括：打包优化，资源管理，注入环境变量。

## 5. 模式(mode)
&emsp;&emsp;通过选择 development, production 或 none 之中的一个，来设置 mode 参数，可以启用 webpack 内置在相应环境下的优化。其默认值为 production。