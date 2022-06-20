---
title: css增强
tags: [webpack]
categories:
  - [webpack]
copyright: true
date: 2022-06-16 06:41:48
---

使用`postcss-loader`和`postcss`及`postcss-preset-env`
<!-- more -->

```js
module.exports = {
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: [
          "style-loader",
          {
            loader: "css-loader",
            options: { importLoaders: 1 },
          },
          {
            loader: "postcss-loader",
            options: {
              postcssOptions: {
                plugins: [
                  [
                    "postcss-preset-env",
                    {
                      // Options
                    },
                  ],
                ],
              },
            },
          },
        ],
      },
    ],
  },
};
```

或者
```js
module.exports = {
  module: {
    rules: [
     {
        test: /\.less$/,
        use: [
            // 'style-loader',
            MiniCssExtractPlugin.loader,
            'css-loader',
            'postcss-loader',
            'less-loader',
        ]
      },
    ],
  },
};
```
添加配置文件`postcss.config.js`, 有效的文件名详见[官方文档](https://webpack.js.org/loaders/postcss-loader/#config)
```js
module.exports = {
    plugins: [
        "postcss-preset-env",
    ],
};
```