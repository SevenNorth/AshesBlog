---
title: 纯前端实现ChatGPT回复效果
tags: [css, js, somethingFunny]
categories:
  - [FE, somethingFunny]
copyright: true
date: 2023-06-28 14:55:00
---

**ChatGPT火了，客户的心也被ChatGPT俘获了。**
客户：你们的问答功能的机器人回复，能像ChatGPT那样一字一字地展示出来，看起来像是有经过思考的样子吗？
产品：好的，我这边跟研发说一下。
我：？？？

<!-- more -->

## ChatGPT 回复效果是如何实现的？
使用Server-sent events实现。
通常来说，一个网页获取新的数据通常需要发送一个请求到服务器，也就是向服务器请求的页面。使用服务器发送事件，服务器可以随时向我们的 Web 页面推送数据和信息。这些被推送进来的信息可以在这个页面上以 事件 + 数据 的形式来处理。
详情参阅[服务器发送事件](https://developer.mozilla.org/zh-CN/docs/Web/API/Server-sent_events)及[ChatGPT 打字机消息回复实现原理](https://juejin.cn/post/7229632570374783034)。

## 纯前端实现回复效果

### 思路
  将获取到的字符串答案，拆分成数组，一个一个往页面上添加。
  可以使用 setInterval 或者 requestAnimationFrame 来实现。最终决定使用 requestAnimationFrame ，理由如下：
  [Why is requestAnimationFrame better than setInterval or setTimeout](https://stackoverflow.com/questions/38709923/why-is-requestanimationframe-better-than-setinterval-or-settimeout)

### 最终效果
![typing](http://sevennorth.lovinghlx.cn/imgbed/typing.gif)
### 代码实现
  两个元素，一个容纳文字，一个模拟光标。
  ```html
   <div class="wordbox">
        <span id="content">
        </span>
        <span id="caret">
        </span>
    </div>
  ```
  使用css动画模拟光标闪烁。
  ```css
  #caret {
      display: inline-block;
      width: 10px;
      height: 1rem;
      box-sizing: border-box;
      border-bottom: 3px solid #fff;
      animation: blink-caret 0.2s step-end infinite;
  }

  .hide {
      display: none !important;
  }

  @keyframes blink-caret {

      from,
      to {
          opacity: 0;
      }

      50% {
          opacity: 1;
      }
  }
  ```
  使用js动态修改DOM内容
  ```javascript
  const str = `
    渔舟逐水爱山春，两岸桃花夹去津。
    坐看红树不知远，行尽青溪不见人。
    山口潜行始隈隩，山开旷望旋平陆。
    遥看一处攒云树，近入千家散花竹。
    樵客初传汉姓名，居人未改秦衣服。
    居人共住武陵源，还从物外起田园。
    月明松下房栊静，日出云中鸡犬喧。
    惊闻俗客争来集，竞引还家问都邑。
    平明闾巷扫花开，薄暮渔樵乘水入。
    初因避地去人间，及至成仙遂不还。
    峡里谁知有人事，世中遥望空云山。
    不疑灵境难闻见，尘心未尽思乡县。
    出洞无论隔山水，辞家终拟长游衍。
    自谓经过旧不迷，安知峰壑今来变。
    当时只记入山深，青溪几度到云林。
    春来遍是桃花水，不辨仙源何处寻。
  `;
  let strArr = str.split('');
  const contentDom = document.getElementById('content');
  const caret = document.getElementById('caret');
  let previousTimeStamp = 0;
  let handle;
  function typewriter(timestamp) {
      if ((timestamp - previousTimeStamp) > 200) {
          contentDom.innerHTML += strArr.shift();
          previousTimeStamp = timestamp;
      }
      if (strArr.length > 0) {
          handle = requestAnimationFrame(typewriter)
      } else {
          caret.classList.add('hide');
      }
  }
  function reset() {
      strArr = str.split('');
      contentDom.innerHTML = '';
      caret.classList.remove('hide');
      handle && cancelAnimationFrame(handle);
  }
  function start() {
      handle = requestAnimationFrame(typewriter);
  };
  function stopTyping() {
      handle && cancelAnimationFrame(handle);
  }
  ```
  requestAnimationFrame 会返回一个 long 整数，是回调列表中唯一的标识。是个非零值，没有别的意义。传这个值给 cancelAnimationFrame() 可以取消回调函数请求。
  (PS: type完一句诗之后，会闪烁好几下没有文字输入是因为换行代来的换行符和空白字符。)

---------------
水完了， 哈哈哈