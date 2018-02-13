/* eslint no-console:0 */
// To reference this file, add <%= javascript_pack_tag 'application' %>

import 'regenerator-runtime/runtime'
import "babel-polyfill"
import Vue             from 'vue'
import axios           from 'axios'
import Notifications   from 'vue-notification'

Vue.use(Notifications)
Vue.prototype.$http = axios

import { AppRouter }   from '../../routes'
import AppStore        from '../../store'
import {i18n}          from '../../locales'
import App             from '../../components/app.vue'
import Api             from '../../api/api'
import VueBreadcrumbs  from '../../components/breadcrumbs.vue'

Vue.prototype.$api  = Api
Vue.use(VueBreadcrumbs)
Vue.component('breadcrumbs', VueBreadcrumbs)

import '../../components/general/dialogs'

export function createApp () {
  const router = AppRouter()
  
  /*
  // check the presence of the meta field, and if true check the if the user is authenticated
  router.beforeEach((to, from, next) => {
    if(to.meta.notRequiresAuth) { // check the meta field 
	  next()
	}
	else {
      if(store.state.Authenticated) { // check if the user is authenticated
          next() // the next method allow the user to continue to the router 
      }
      else {
          next('/') // Redirect the user to the main page
      }
    }
  })
  // <div v-if="this.$store.state.authenticated"> Element for not Guests </div>
  */
  
  const app = new Vue({
	i18n,
	router,
	store: AppStore,
    render: h => h(App),
  })
  
  return { app, router }
}
