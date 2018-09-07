# umi-plugin-locale-yaml

`umi`多语言控制插件YAML版本。

基于[umi-plugin-locale](https://github.com/umijs/umi/tree/master/packages/umi-plugin-locale)实现。

## 配置 (如果使用了umi-plugin-react，需要关闭locale配置)

**.umirc.js**

```js
export default {
  plugins: [
    [
      'umi-plugin-locale-yaml',
      {
        locale: {
          default: 'zh-CN', //默认语言 zh-CN
          baseNavigator: true, // 为true时，用navigator.language的值作为默认语言
          antd: true // 是否启用antd的<LocaleProvider />
        }
      }
    ]
  ]
};
```

## 目录及约定

```
.
├── dist/                          
├── mock/                         
└── src/                          
    ├── layouts/index.js          
    ├── pages/                    
    └── locales               // 多语言文件存放目录，里面的文件会被umi自动读取
        ├── zh-CN.yml
        └── en-US.yml
├── .umirc.js                     
├── .env                          
└── package.json
```


>如果`.umirc.js`里配置了`singular: true`，`locales`要改成`locale`


## 多语言文件约定

多语言文件的命名规范：`<lang>-<COUNTRY>.yml`


多语言文件的内容规范：键-值组成的字面量，如下：

zh-CN.yml

```javascript
App:
  appName: 国际化
  version: 版本
  copyright: C
```

en-US.yml

```javascript
App:
  appName: i18n
  version: Ver
  copyright: C
```

## 使用方法同 umi-plugin-locale  仅修改了读取的配置文件格式
