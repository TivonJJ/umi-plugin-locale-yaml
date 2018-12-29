# umi-plugin-locale-yaml

`umi`多语言控制插件YAML版本。

基于[umi-plugin-locale](https://github.com/umijs/umi/tree/master/packages/umi-plugin-locale)实现。
>  使用方法同 umi-plugin-locale  仅修改了读取的配置文件格式yml配置

## 配置 (如果使用了umi-plugin-react/umi-plugin-locale，需要关闭locale配置)

**.umirc.js**

```js
export default {
  plugins: [
    [
      'umi-plugin-locale-yaml',
      {
        locale: {
          enable: true, // 是否启用 默认false
          default: 'zh-CN', //默认语言 zh-CN
          baseNavigator: true, // 为true时，用navigator.language的值作为默认语言
          antd: true, // 是否启用antd的<LocaleProvider />
          async:{ // 是否单独异步加载国际化配置，会被单独打包成一个文件，大型项目推荐使用，可选设置loadingComponent,如果不需要直接设置成true
              loadingComponent: './components/PageLoading/index', // 国际化文件加载时渲染
          },
          ignoreError:{ // 是否忽略错误，在传入id错误时候会报错，造成程序无法继续往下走，忽略后只会报错单不会终止执行 无option可设置为true
              message: '-' // 错误后默认显示的文字，不设置默认会显示错误的message
          }
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

支持import载入合并文件功能 基于 [yaml-import](https://www.npmjs.com/package/yaml-import) 实现
多语言文件的内容规范：键-值组成的字面量，如下：

zh-CN.yml

```javascript
App:
  appName: 国际化
  version: 版本
  copyright: C
  desc:
    title: 标题
    content: 内容
Page: !!import/single userPage.yaml
Sys: !!import/dirMerge [ 'sysPage','dir2']
```

en-US.yml

```javascript
App:
  appName: i18n
  version: Ver
  copyright: C
  desc:
      title: title
      content: content
Page: !!import/single userPage.yaml
Sys: !!import/dirMerge [ 'sysPage', 'dir2']
```

> yml 会被转换成平级的与原来json配置一样的格式，所以使用的方式不变。

```
 formatMessage({id:'App.appName'}) // i18n
```