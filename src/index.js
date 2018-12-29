import {join, dirname} from 'path';
import {
    existsSync,
    statSync,
    readdirSync,
    readFileSync,
    writeFileSync,
    mkdirSync,
} from 'fs';
import {winPath} from 'umi-utils';
import Mustache from 'mustache';
import yimp from 'yaml-import';
import flat from 'flat';

// export for test
export function getLocaleFileList(absSrcPath, singular) {
    const localeList = [];
    const localePath = join(absSrcPath, singular ? 'locale' : 'locales');
    if (existsSync(localePath)) {
        const localePaths = readdirSync(localePath);
        for (let i = 0; i < localePaths.length; i++) {
            const fullname = join(localePath, localePaths[i]);
            const stats = statSync(fullname);
            const fileInfo = /^([a-z]{2})-([A-Z]{2})\.(ya?ml)$/.exec(localePaths[i]);
            if (stats.isFile() && fileInfo) {
                localeList.push({
                    lang: fileInfo[1],
                    country: fileInfo[2],
                    name: `${fileInfo[1]}-${fileInfo[2]}`,
                    src: winPath(fullname),
                });
            }
        }
    }
    return localeList;
}

export default function (api, options = {}) {
    const {config, paths} = api;

    api.addPageWatcher(
        join(paths.absSrcPath, config.singular ? 'locale' : 'locales'),
    );

    api.onOptionChange(newOpts => {
        options = newOpts;
        api.rebuildTmpFiles();
    });

    api.addRendererWrapperWithComponent(() => {
        const localeFileList = getLocaleFileList(paths.absSrcPath, config.singular);
        const wrapperTplJsx = options.async?'wrapper_async.jsx.tpl':'wrapper.jsx.tpl';
        let wrapperTpl = readFileSync(
            join(__dirname, '../template/'+wrapperTplJsx),
            'utf-8',
        );
        wrapperTpl = wrapperTpl.replace('<%= loadingComponent %>',getLoading());
        const localesDir = join(paths.absTmpDirPath, './locales');
        if(!existsSync(localesDir))mkdirSync(localesDir);
        localeFileList.forEach(item=>{
            const yamlObj = yimp.read(item.src);
            const messages = flat.flatten(yamlObj);
            item.path = winPath(join(localesDir,item.name+'.json'));
            writeFileSync(item.path, JSON.stringify(messages), 'utf-8');
        });
        const defaultLocale = options.default || 'zh-CN';
        const wrapperContent = Mustache.render(wrapperTpl, {
            async:options.async,
            ignoreError:JSON.stringify(options.ignoreError),
            localeList: localeFileList,
            antd: options.antd === undefined ? true : options.antd,
            baseNavigator:
                options.baseNavigator === undefined ? true : options.baseNavigator,
            useLocalStorage: true,
            defaultLocale,
            defaultLang: defaultLocale.split('-')[0],
            defaultAntdLocale: defaultLocale.replace('-', '_'),
        });
        const wrapperPath = join(paths.absTmpDirPath, './LocaleWrapper.jsx');
        writeFileSync(wrapperPath, wrapperContent, 'utf-8');
        return wrapperPath;

        function getLoading() {
            let codes = ['let loadingComponent = null'];
            if(typeof options.async==='object' && options.async.loadingComponent){
                codes.push(`const Component = require('${winPath((0,join)(paths.absSrcPath, options.async.loadingComponent))}').default`,
                    `loadingComponent = <Component/>`)
            }
            codes.push(`if(this.state.loading)return loadingComponent`);
            return codes.join('\n  ')
        }
    });

    api.modifyAFWebpackOpts(memo => {
        return {
            ...memo,
            alias: {
                ...(memo.alias || {}),
                'umi/locale': join(__dirname, './locale.js'),
                'react-intl': dirname(require.resolve('react-intl/package.json')),
            },
        };
    });
}
