
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
    messages: require('{{{path}}}'),
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

export default (props) => {
  let ret = props.children;
  {{#localeList.length}}
  ret = (<IntlProvider locale={appLocale.locale} messages={appLocale.messages}>
    <InjectedWrapper>{ret}</InjectedWrapper>
  </IntlProvider>)
  {{/localeList.length}}
  {{#antd}}
  ret = (<LocaleProvider locale={appLocale.antd || defaultAntd}>
    {ret}
  </LocaleProvider>);
  {{/antd}}
  return ret;
}
