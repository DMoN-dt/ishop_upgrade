import Vue             from 'vue'
import VueI18n         from 'vue-i18n'
import messages        from 'locales/lang/'

Vue.use(VueI18n)


export const i18n = new VueI18n({
	locale: 'ru',
	fallbackLocale: 'ru',
	messages,
	//dateTimeFormats: dateTimeFormats,
    //numberFormats: numberFormats
})

const loadedLanguages = ['ru'] // default language that is preloaded


function setI18nLanguage (lang) {
  i18n.locale = lang
  axios.defaults.headers.common['Accept-Language'] = lang
  document.querySelector('html').setAttribute('lang', lang)
  return lang
}


export function loadLanguageAsync (lang) {
  if(i18n.locale !== lang) {
    if(!loadedLanguages.contains(lang)) {
      return import(/* webpackChunkName: "lang-[request]" */ `locales/lang/${lang}`).then(msgs => {
        i18n.setLocaleMessage(lang, msgs.default)
        loadedLanguages.push(lang)
        return setI18nLanguage(lang)
      })
    } 
    return Promise.resolve(setI18nLanguage(lang))
  }
  return Promise.resolve(lang)
}

/*
Using the loadLanguageAsync function is straight forward. A common use case is inside a vue-router beforeEach hook.

router.beforeEach((to, from, next) => {
  const lang = to.params.lang
  loadLanguageAsync(lang).then(() => next())
})

We could improve this by checking if the lang is actually supported by us or not, call reject so we can catch that in the beforeEach stopping the route transition.
*/