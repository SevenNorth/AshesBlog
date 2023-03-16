---
title: 使用PixiJS做一个小游戏(1)
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

## 创建并显示Sprite
舞台已搭好，演员请就位~
任何想要在渲染器中可见的东西都必须添加到一个特殊的 `Pixi` 对象中，这个对象叫做stage(舞台)，就是上面的 `app.stage`。

stage(舞台)是Pixi的Container(容器)对象。可以把一个Container(容器)想象成一种空盒子，它会把放进去的东西组合在一起并储存起来。stage(舞台)对象是<font color='#f00'>场景中所有可见事物的根容器</font>。在stage(舞台)里放的任何东西都可以在canvas画面上渲染出来。(重要:因为stage(舞台)是一个PixiContainer(容器)，所以它具有与任何其他Container(容器)对象相同的属性和方法。但是，尽管stage(舞台)具有width和height属性，它们并不涉及呈现窗口的大小。舞台的有width和height属性只是告诉你它的面积!)。

Sprite是PixiJS中最简单和最常见的可渲染对象。它们代表要在屏幕上显示的单个图像。每个Sprite都包含一个要绘制的[纹理](https://pixijs.download/release/docs/PIXI.Texture.html)，以及在场景图中运行所需的所有变换和显示状态。可以控制它们的位置、大小和其他属性。通过制作和控制Sprite，来实现对游戏角色的操控。

- 创建Sprite可以通过两种方式:
  1. 直接从图片创建
     ```typescript
      import { Sprite } from 'pixi.js';
      const sprite = Sprite.from('images/anySpriteImage.png');
     ```
  2. 先加载到纹理缓存，再创建精灵
     ```typescript
      import { Assets, Sprite } from 'pixi.js';

      await Assets.load('images/anySpriteImage.png');
      const texture = PIXI.utils.TextureCache["images/anySpriteImage.png"];
      const sprite = new PIXI.Sprite(texture);
     ```
  3. 通过雪碧图创建
     可以通过定义与要提取的子图像大小和位置相同的矩形区域来从雪碧图捕获子图像。


- 显示sprite
  显示sprite只需要一句代码：
  ```typescript
  app.stage.addChild(sprite);
  ```
  当然，也可以把创建的sprite添加到其他的容器当中。
- 设置sprite的位置
  设置sprite的`x`，`y`属性可以调整sprite在舞台中的位置
  ```typescript
  sprite.x = 96;
  sprite.y = 96;
  ```
  sprite的定位锚点是它自身的左上角， 当然定位锚点(anchor)可以通过以下方式进行设置。但是，建议所有的sprite的锚点都保持一致，便于后续计算碰撞。
  ```typescript
  // The default is (0,0), this means the sprite's origin is the top left.
  // Setting the anchor to (0.5,0.5) means the sprite's origin is centered.
  // Setting the anchor to (1,1) would mean the sprite's origin point will be the bottom right corner.
  // This will set the origin to center. (0.5) is same as (0.5, 0.5).
  sprite.anchor.set(0.5); 
  ```
  pixi中采用与css定位系统类似的屏幕坐标系，见下图：
  ![坐标系](http://sevennorth.lovinghlx.cn/imgbed/坐标系.png)


## 移动Sprite

移动Sprite的本质是动态的修改spirte的坐标属性(即x,y)。
创建的`app`会带有一个`ticker`对象，Ticker类可以自行查阅文档，我也是麻的。简单的说Ticker类就是一个运行更新循环的类，可以通过`add`方法注册需要执行的函数，直到这个函数被移除或者`ticker`停止。通过`add`添加到`ticker`的函数，每秒都会被执行60次(默认,可以配置)。
另外，如果不使用ticker来进行循环，也可以使用`requestAnimationFrame`方法来实现游戏循环。
```typescript
function gameLoop(delta){
  sprite.x += 1;
}
app.ticker.add(delta => gameLoop(delta));
```
这样，就可以看到sprite逐渐移动到舞台右侧。

但是，这样并不利于有效的实现控制sprite的移动。
我这里是创建了一个Player的类，包含了x,y,vx,vy,speed,sprite等属性，后续考虑使用dx,dy代替vx,vy,用`1`和`-1`来表示方向,方向×速度就是这一帧的sprite的偏移量。在构造函数中调用相关方法创建Pixi的Sprite对象，并将其挂到sprite属性。

定义一个`keyboard`函数，用于监听并捕获事件。
```javascript
 function keyboard(keyCode) {
  let key = {};
  key.code = keyCode;
  key.isDown = false;
  key.isUp = true;
  key.press = undefined;
  key.release = undefined;
  // 按下按键时的处理程序
  key.downHandler = event => {
    if (event.keyCode === key.code) {
      if (key.isUp && key.press) key.press();
      key.isDown = true;
      key.isUp = false;
    }
    event.preventDefault();
  };
  // 按键被松开时的处理程序
  key.upHandler = event => {
    if (event.keyCode === key.code) {
      if (key.isDown && key.release) key.release();
      key.isDown = false;
      key.isUp = true;
    }
    event.preventDefault();
  };
  // 添加事件监听器
  window.addEventListener('keydown', key.downHandler.bind(key), false);
  window.addEventListener('keyup', key.upHandler.bind(key), false);
  // 返回key对象
  return key;
}
```

创建key对象并绑定相应事件
```typescript
bindKeyEvent() {
   const left = keyboard(37);
   //左箭头键 按下
    left.press = () => {
      this.vx = -this.speed;
      this.vy = 0;
    };
    //左箭头键 释放
    left.release = () => {
      if (!this.gameState.playing) return;
      //如果左箭头已被释放，右箭头未按下，并且精灵没有垂直移动，则将 vx 设置为0来停止精灵移动。
      if (!right.isDown && this.vy === 0) {
        this.vx = 0;
      }
    };
    // ...
}
```
`bindKeyEvent`事件会在Player类实例化时进行调用，其他几个键的处理类似。
Player类中，我增加了一个move方法，用于更新sprite坐标，进行移动。
```typescript
move() {
  if (this.sprite) {
    let next_X = this.x + (this.vx ?? 0);
    let next_y = this.y + (this.vy ?? 0);
    this.x = next_X;
    this.y = next_y;
    this.sprite.x = next_X;
    this.sprite.y = next_y;
  }
}
```
现在，就可以我们操sprite在舞台上运动起来了
```typescript
const person = new Player({
  // ...
});
app.ticker.add(person.move, person);
```

---------
下一节,我将介绍如何人物添加动作(行走、转身).