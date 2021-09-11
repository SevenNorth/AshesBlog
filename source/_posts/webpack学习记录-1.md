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
