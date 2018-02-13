
export default {
  state: {
	Currencies: null,
	ProductQuantityMeasureUnits: null,
	
	Sellers: {},
	Customers: {},
	activeSellerId: null,
	activeCustomerId: null,
  },
  
  mutations: {
	CURRENCIES_SET(state, data){
		state.Currencies = data
	},
	
	SET_ACTIVE_SELLER_ID (state, {id}){
		state.activeSellerId = id
	},
	
	SET_ACTIVE_CUSTOMER_ID (state, {id}){
		state.activeCustomerId = id
	},
  },
  
  getters: {
	getSeller: (state) => ({Sellers, activeSellerId}) => {
		if(!Sellers || (typeof activeSellerId == 'undefined'))return null;
		return Sellers.find((seller) => seller.id === activeSellerId) || null
	},
  },
  
  actions: {
	  async setCurrencies (context, data){
		context.commit('CURRENCIES_SET', data)
	  },
	  
	  async setProductQuantityMeasureUnits (context, data){
		context.commit('DATA_ARRAY_ADD_FULL_DATA', {node: 'measure_units', data})
	  },
	  
	  async getProductQuantityMeasureUnitById (context, id){
		return await context.dispatch('DataArray_getItemFullData', {
			node: 'measure_units', id,
			api_func: 'general.measure_units.show',
		})
	  },
	  
	  async setActiveSellerId (context, data){
		context.commit('SET_ACTIVE_SELLER_ID', data)
	  },
	  
	  async setActiveCustomerId (context, data){
		context.commit('SET_ACTIVE_CUSTOMER_ID', data)
	  },
  },
}
