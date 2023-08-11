---
title: 使用PixiJS做一个小游戏(2)
tags: [canvas, pixijs]
categories:
  - [game]
copyright: true
date: 2023-03-16 17:13:25
---

  上一节，我们已经学会了如何创建应用、在页面上显示舞台、创建精灵并将精灵添加到舞台及通过键盘控制sprite进行移动。这一节，我们将使用一个额外的工具，更好的去创建我们的sprite。

<!-- more -->

## 让sprite动起来
  这里的动起来，不是指的位置的移动，而是指sprite看起来用有一些动作，如行走、转身等。
  ![pkq_1](http://sevennorth.lovinghlx.cn/imgbed/pkq_1.gif)

  要让精灵在不断运动，成为一个动画精灵，可以使用动画精灵。
  动画精灵指的是按顺序使用一系列略有不同的图像，创建的精灵，之后一帧一帧的播放这些图像，就可以产生运动的幻觉。
  就是用这种图片：
![pikaqiu](http://sevennorth.lovinghlx.cn/imgbed/pikaqiu.png)
  做出这种效果
  ![running](http://sevennorth.lovinghlx.cn/imgbed/running.gif)

  要制作动画精灵我们需要用到 PixiJS 的 [AnimatedSprite](https://pixijs.download/dev/docs/PIXI.AnimatedSprite.html) 。

  使用官方的 AnimatedSprite 创建纹理数组时比较麻烦，可以用名叫 [SpriteUtilities](https://github.com/kittykatattack/spriteUtilities/tree/master/src) 的库，该库包含许多有用的函数，用于创建Pixi精灵并使它们更易于使用。
  使用时，需要对该工具进行实例化，然后用该工具创建精灵。

  在该项目中，用SpriteUtilities创建的精灵，多了一些属性，故对Sprite类型做了拓展
  ```typescript
  import { Sprite } from 'pixi.js';

  export interface ISprite extends Sprite {
    playAnimation: (sequenceArray: number[]) => void;
    show: (frameNumber: number) => number;
    fps: number;
    customId?: string; // 怪物ID
  }
  ```

  现在创建精灵，就可以该工具创建了
  ```typescript
    const imgUrl = 'path_to_your_img';
    await Assets.load(imgUrl);
    const su = new SpriteUtilities();
    const frames = su.filmstrip(imgUrl, this.size.width, this.size.height);
    this.sprite = su.sprite(frames) as ISprite;
  ```

  首先，要用将资源加载进来，然后用工具的 filmstrip 方法 创建具体的图像帧
  第一个参数是图片的地址，后面参数是 帧的宽高，也就是创建的精灵的宽高，根据传入的宽高，对雪碧图进行裁切，返回裁切后的获得的帧；
  然后，使用sprite创建动画精灵，参数就是上一步创建的图像帧。