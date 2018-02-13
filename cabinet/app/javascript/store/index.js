import Vue  from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

import store_Tokens 		from './modules/general/tokens'
import store_Storage		from './modules/general/storage'
import store_DataArray      from './modules/general/data_array'
import store_Cabinet		from './modules/cabinet'


export default new Vuex.Store({
  state: {
    App: null,
  },
  modules : {
	  storage:     store_Storage,
	  tokens:      store_Tokens,
	  data_array:  store_DataArray,
	  cabinet:     store_Cabinet,
  }
})
