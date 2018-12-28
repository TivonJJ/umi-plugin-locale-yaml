import React from 'react';
{{#localeList.length}}
import { addLocaleData, IntlProvider, injectIntl } from 'react-intl';
import { _setIntlObject } from 'umi/locale';

const InjectedWrapper = injectIntl(function(props) {
  _setIntlObject(props.intl);
  return props.children;
})
{{/localeList.length}}

const baseNavigator = {{{baseNavigator}}};
const useLocalStorage = {{{useLocalStorage}}};

{{#antd}}
import { LocaleProvider } from 'antd';
const defaultAntd = require('antd/lib/locale-provider/{{defaultAntdLocale}}');
{{/antd}}

const localeInfo = {
  {{#localeList}}
  '{{name}}': {
    messages: {},
    locale: '{{name}}',
    {{#antd}}antd: require('antd/lib/locale-provider/{{lang}}_{{country}}'),{{/antd}}
    data: require('react-intl/locale-data/{{lang}}'),
  },
  {{/localeList}}
};

let appLocale = {
  locale: '{{defaultLocale}}',
  messages: {},
  data: require('react-intl/locale-data/{{defaultLang}}')
};
if (useLocalStorage && localStorage.getItem('umi_locale') && localeInfo[localStorage.getItem('umi_locale')]) {
  appLocale = localeInfo[localStorage.getItem('umi_locale')];
} else if (localeInfo[navigator.language] && baseNavigator){
  appLocale = localeInfo[navigator.language];
} else {
  appLocale = localeInfo['{{defaultLocale}}'] || appLocale;
}
window.g_lang = appLocale.locale;
{{#localeList.length}}
appLocale.data && addLocaleData(appLocale.data);
{{/localeList.length}}

export default class extends React.PureComponent {
    state={
        loading:true
    };
    componentDidMount(){
        import(/* webpackChunkName: "locale" */ `./locales/${appLocale.locale}`).then(({default:_})=>{
            appLocale.messages = _;
        },err=>{
            throw err;
        }).finally(()=>{
            this.setState({loading:false})
        })
    }
    render(){
        <%= loadingComponent %>;
        let ret = this.props.children;
        {{#localeList.length}}
        ret = (<IntlProvider locale={appLocale.locale} messages={appLocale.messages}>
          <InjectedWrapper>{ret}</InjectedWrapper>
        </IntlProvider>)
        {{/localeList.length}}
        {{#antd}}
        ret = (<LocaleProvider locale={appLocale.antd ? (appLocale.antd.default || appLocale.antd) : defaultAntd}>
          {ret}
        </LocaleProvider>);
        {{/antd}}
        return ret;
    }
}
