import store_Ecommerce from './ecommerce/index.js'
import store_Seller from './ecommerce/seller'


export default {
  state: {
    CabinetGeneralInfo: {},
  },
  
  mutations: {
	CABINET_GENERAL_INFO_SET(state, data){
		state.CabinetGeneralInfo = data
	},
	
	CABINET_GENERAL_INFO_CLEAR(state){
		state.CabinetGeneralInfo = {}
	},

  },
  
  //getters: {
  //},
  
  actions: {
	  async clearCabinetGeneralInfo (context){
		context.commit('CABINET_GENERAL_INFO_CLEAR')
	  },
	  
	  async loadCabinetGeneralInfo (context){
		let response = await context.rootState.App.$api.cabinet.fetchGeneralInfo(context)
		if(response.result && response.result.data){
			context.commit('CABINET_GENERAL_INFO_SET', response.result.data)
		}
	  },
  },
  
  modules : {
	  ecommerce: store_Ecommerce,
	  seller: store_Seller,
  }
}
