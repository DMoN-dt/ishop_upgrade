
import store_ProductsGroups from './products_groups'

export default {
  state: {
	SellerId: null,
	SellerIdCallbacks: [],
	
	GovTaxes: null,
    GovTaxSystems: null,
    Defaults: {
		Currency: null,
		GovTaxSystem: null,
		GovTax: null,
	
		PriceIncTax: null,
		ShowPriceIncTax: null,
		ShowPriceAsIs: null,
		ShowPriceNoChange: null,
		ProdMeasureUnit: null,
	},
	SysTasks: {},
  },
  
  mutations: {
	SELLER_ID_SET(state, id){
		state.SellerId = id
	},
	
	GOV_TAXES_SET(state, {gov_tax_systems, gov_taxes}){
		if(typeof gov_tax_systems != 'undefined')state.GovTaxSystems = gov_tax_systems;
		if(typeof gov_taxes != 'undefined')state.GovTaxes = gov_taxes;
	},
	
	DEFAULTS_SET(state, {def_currency, def_gov_tax_system, def_gov_tax, def_price_w_tax, def_show_price_w_tax, def_show_price_as_is, def_show_price_nochange, def_prod_measure_unit}){
		if(typeof def_currency != 'undefined')state.Defaults.Currency = def_currency;
		if(typeof def_gov_tax_system != 'undefined')state.Defaults.GovTaxSystem = def_gov_tax_system;
		if(typeof def_gov_tax != 'undefined')state.Defaults.GovTax = def_gov_tax;
		
		if(typeof def_price_w_tax != 'undefined')state.Defaults.PriceIncTax = def_price_w_tax;
		if(typeof def_show_price_w_tax != 'undefined')state.Defaults.ShowPriceIncTax = def_show_price_w_tax;
		if(typeof def_show_price_as_is != 'undefined')state.Defaults.ShowPriceAsIs = def_show_price_as_is;
		if(typeof def_show_price_nochange != 'undefined')state.Defaults.ShowPriceNoChange = def_show_price_nochange;
		if(typeof def_prod_measure_unit != 'undefined')state.Defaults.ProdMeasureUnit = def_prod_measure_unit;
	},
	
	SYSTEM_TASK_SET(state, {task_name, task_data}){
		if(!state.SysTasks)state.SysTasks = {};
		if((typeof state.SysTasks[task_name] == 'undefined') || (task_data != null))state.SysTasks[task_name] = task_data;
	},
	
	SYSTEM_TASKS_SET(state, data){
		state.SysTasks = data
	},
  },
  
  actions: {
	async activeSellerName (context, {callback, params}){
		context.state.SellerIdCallbacks.push({func: callback, params})
		context.dispatch('execCallbacksSellerId', {func: callback, params})
	},
	
	async setSellerId (context, value){
		await context.commit('SELLER_ID_SET', value)
		context.dispatch('execCallbacksSellerId')
	},
	
	execCallbacksSellerId (context, callback){
		if(typeof callback != 'undefined')callback.func(context.getters.getActiveSellerName, callback.params)
		else {
			context.state.SellerIdCallbacks.forEach(function(callb){callb.func(this, callb.params)}, context.getters.getActiveSellerName)
			context.state.SellerIdCallbacks = []
		}
	},
	
	async setSellerGovTaxes (context, data){
		context.commit('GOV_TAXES_SET', data)
	},
	
	async setSellerDefaults (context, data){
		context.commit('DEFAULTS_SET', data)
	},
	
	setSellerSystemTask (context, data){
	  context.commit('SYSTEM_TASK_SET', data)
    },
	
	setSellerSystemTasks (context, data){
	  context.commit('SYSTEM_TASKS_SET', data)
    },
	
	is_enabled_SellerSystemTask (context, task_name){
	  return (this.SysTasks[name] && this.SysTasks[name].enabled)
    },
	
	is_applicable_or_absent_SellerSystemTask (context, {name, time_to_check}){
		return (!this.SysTasks[name] || (
			this.SysTasks[name].enabled && (
				!this.SysTasks[name].enabled_at || (time_to_check >= this.SysTasks[name].enabled_at)
			)
		))
	},
  },
  
  
  getters: {
	getActiveSellerName: (state) => {
		if((typeof state.SellerId != 'undefined') && (state.SellerId != null)){
			return ((state.SellerId == 0) ? 'Магазин' : ('Продавец №' + state.SellerId))
		} else return null;
	}
  },

  
  modules : {
	  products_groups: store_ProductsGroups,
  }
}
