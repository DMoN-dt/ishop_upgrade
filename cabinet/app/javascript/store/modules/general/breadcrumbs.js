
const state = {
	activeSellerId: null,
}


const mutations = {
	SET_ACTIVE_SELLER_ID (state, seller_id){
		state.activeSellerId = seller_id
	},
}


//const getters: {
//	activeSeller: ({sellers, activeSellerId}) => {
//		return sellers.find((seller) => seller.id === activeSellerId) || null
//	},
//}


export default {
  state,
  mutations,
  //getters,
}