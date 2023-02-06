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
  由于个人原因想复习一下webpack配置，所以使用了第二种方式：webpack + ts。
  搭建过程参考掘金的[【前端工程化】webpack5从零搭建完整的react18+ts开发和打包环境](https://juejin.cn/post/7111922283681153038)，移除了react部分相关的依赖和配置；顺便搞了代码及样式格式，参考[【前端工程化】配置React+ts项目完整的代码及样式格式和git提交规范](https://juejin.cn/post/7101596844181962788)，没有搞 `husky`及git提交规范。
  提前处理一个样式问题，由于`canvas`标签的默认的display属性是'inline-block'，即便是设置为宽高都是100%，也会在页面出现滚动条，所以需要我们把它设置为'block'。跟着第一篇文章搭建使用了`purgecss-webpack-plugin`来清理未使用的css样式，会在生产环境构建时把在在less文件中写的canvas相关的样式给移除掉(pixi绘制所需的`canvas`标签是通过Pixi相关方法创建的，然后append挂在到document的相应节点，所以在构建的时候，不会有canvas标签存在)，所以需要给PurgeCSSPlugin配置safelist属性。
  ```javascript
  // ...
  new PurgeCSSPlugin({
      // ...
      safelist: {
        standard: ['canvas'], // 过滤以canvas标签，哪怕没用到也不删除
      },
    }),
  // ...
  ```

---------------------

## 创建Pixi应用
使用Pixi的Application对象创建一个矩形显示区域。Application是一个辅助类，可以简化 PixiJS 的使用。它创建了渲染器，舞台，并启动用于更新的ticker。目前，Application类是开始使用PixiJS而无需担心细节的完美方式。它会自动生成一个`canvas`元素，然后在canvas画布上显示图像。需要手动将这个`canvas`元素挂载到document的对应节点。
  ```typescript
  import { Application } from 'pixi.js';

  const root = document.getElementById('root');
  const width = root?.clientWidth ?? 1600,
    height = root?.clientHeight ?? 800;
  const app = new Application({
    width,
    height,
    background: '#1099bb',
    antialias: true,
    resolution: 1,
  });
  root?.appendChild(app.view as unknown as Document);
  ```
  这样，我们就能看到一整块蓝色的canvas背景了。

