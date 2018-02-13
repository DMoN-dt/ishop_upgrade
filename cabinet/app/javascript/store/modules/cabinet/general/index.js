// UnUsable
const state = {
	
}


const mutations = {
	
}


const actions = {
	async clearCabinetGeneralInfo (context){
		state.CabinetGeneralInfo = {}
	  },
	  
	  async loadCabinetGeneralInfo (context){
		let response = await context.rootState.App.$api.fetchCabinetGeneralInfo(context)
		if(response.result && response.result.data){
			state.CabinetGeneralInfo = response.result.data
		}
	  },
}


export default {
  state,
  mutations,
  actions,
}