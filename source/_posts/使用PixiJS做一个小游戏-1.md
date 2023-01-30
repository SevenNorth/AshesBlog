---
title: 三天时间用PixiJS做一个小游戏(1)
tags: [canvas, pixijs]
categories:
  - [game]
copyright: true
date: 2023-01-30 11:20:02
---

  年前一周无心工作，办公室好多人都请假5+2，然而我请假不知道干啥，于是乎——摸鱼！摸鱼做点啥好呢？
  水群的时候，都在聊到游戏公司又是年后又是抽奖的，眼馋坏了(今年年终都没有，还裁了好几个hxd， o(╥﹏╥)o)
  说到游戏，我曾经也是做了一个web的贪吃蛇，纯js操作dom(毕竟那会儿刚学校前端开发)，当时做碰撞的逻辑做了好久呢。现在看来就是写的一坨大便。。。[源码在此](https://github.com/SevenNorth/webSnake)，[在线体验](https://sevennorth.github.io/webSnake/)(ps: 方向键进行控制, 肉眼可见的丢帧)。
  步入正题，这次想做的是一个可以操控人物打怪的小游戏。网上查询了一番，考虑库的更新情况，现有文档及中文文档，以及大佬们开贴记录的问题及实现的demo情况，最终选择了[PixiJS](https://pixijs.com/)，来进行开发。
  游戏基本操作及逻辑已经完成，可以[在线体验](http://game.lovinghlx.cn/)， 诸多不足，还请指正。

<!-- more -->

## PixiJS使用方式
  - 方式一
    在[https://github.com/pixijs/pixijs/releases](https://github.com/pixijs/pixijs/releases)下载需要的版本，使用 `script` 标签引入pixijs, 也可以直接使用在线cdn资源。通过vscode插件：`Live Server` 启动。直接在html文件中编写逻辑或者抽离成单独的js文件，通过 `script` 标签引入。
  - 方式二
    使用webpack + ts进行开发，使用`npm`安装pixijs依赖。同过`import`，导入对应模块或者工具进行使用。
    在npm中搜索出pixijs，发现有两个，使用下载量多的那个，即`pixi.js`。
    ![20230130143832](http://sevennorth.lovinghlx.cn/imgbed/20230130143832.png)
    ```bash
    npm install pixi.js
    # yarn add pixi.js
    ```
    ```typescript
    import * as PIXI from 'pixi.js';
    ```

## 开发环境搭建