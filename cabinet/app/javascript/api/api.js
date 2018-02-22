const _API_HTTP_HEADER_VENDOR = 'DT_Zagruz'

const _API_ROOT = '/api'
const _API_VERSION = 'v1'
const _API_PATH_MUST_CONTAIN_VERSION = true

const _API_HTTP_HEADER_VENDOR_API = (_API_HTTP_HEADER_VENDOR ? ('api.' + _API_HTTP_HEADER_VENDOR) : 'api')
const _API_HTTP_HEADER_SIGN = 'application/vnd.' + (_API_VERSION ? (_API_HTTP_HEADER_VENDOR_API + '.' + _API_VERSION) : _API_HTTP_HEADER_VENDOR_API) + '+json'
const _API_PATH = ((_API_PATH_MUST_CONTAIN_VERSION && (_API_VERSION.length > 0)) ? `${_API_ROOT}/${_API_VERSION}/` : `${_API_ROOT}/`)


export default({
  apiOnFailure (vApp, e) {
	let err_str = ''
	if((typeof e.response != 'undefined') && e.response.statusText){
		err_str = e.response.statusText.toString() + '<br>'
	}
	err_str += e.toString()
	
	vApp.$notify({
      group: 'main',
	  type:  'error',
	  title: 'Ошибка запроса к серверу',
      text: err_str,
    });
  },
  
  async apiQuery (context, method, url, url_params, data, {vApp, with_token, token, skip_stored_token, notify_on_error, with_json_accept, with_user_token} = {}) {
	// Default params
	if(!vApp)vApp = context.rootState.App;
	if(typeof with_token   == 'undefined')with_token = true;
	if(typeof token        == 'undefined')token      = 'none';
	if(typeof skip_stored_token == 'undefined')skip_stored_token = false;
	if(typeof with_user_token   == 'undefined')with_user_token   = false;
	if(typeof with_json_accept  == 'undefined')with_json_accept  = true;
	if(typeof notify_on_error   == 'undefined')notify_on_error   = true;
	
	if(with_user_token)with_token = true;
	
	let response, ttoken = null, stored_token = false
	
	if(with_token || (with_token == null)){
		if((token == 'none') && (url.substr(-13) != '/token_scopes')){
			response = await vApp.$store.dispatch('getActionToken', {method, url, mandatory: (with_token == true), with_user_token, skip_stored: skip_stored_token})
			if(response){
				if(response.cancel){return {}}
				if(response.token){
					ttoken = response.token
					stored_token = (response.stored_token ? true : false)
				}
			}

			if(!ttoken){
				// Inform the user has no rights required and confirm to try action
				with_token = false;
			}
			else if(ttoken == 'none'){with_token = false;}
			
			token = ttoken
		}
	}
	
	let headers = {} //'Content-Type': _API_HTTP_HEADER_SIGN + ';charset=UTF-8'}
	if(with_json_accept){headers['Accept'] = 'application/json';}
	if(with_token){headers['Authorization'] = 'Bearer ' + token;}
	
	try {
		response = await vApp.$http({method, url: `${_API_PATH}${url}`, params: url_params, data, headers})
		console.log('API ANSWER: ', response.data);
		return {result: response.data}
	} catch (e) {
		if(stored_token && !skip_stored_token && e.response && (e.response.status == 400 || e.response.status == 401)){
			return await this.apiQuery(context, method, url, url_params, data, {with_token, token, skip_stored_token: true, with_user_token, notify_on_error})
		}
		if(notify_on_error){this.apiOnFailure(vApp, e);}
		return {errors: [e]}
	}
  },
  
  fetchScopesRequired: (context, {method, url, token, req_action}) => {
	return this.a.apiQuery(context, 'post', `${url}/token_scopes`, null, {method, req_action}, {token, notify_on_error: false})
  },
  
  
  cabinet: {
	fetchGeneralInfo: (context) => {
		return this.a.apiQuery(context, 'post', 'cabinfo', null, null, {with_user_token: true})
	},
  },

  
  general: {
	  countries: {
		  fetchList: (context, {start, maxcnt, order, get_total}) => {
			let data = {limit_num: maxcnt}
			if(order)data['order'] = order;
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			
			return this.a.apiQuery(context, 'get', `countries/`, data)
		  },
		  
		  //show: (context, id = null, code = null) => {
			//if(id)id = 'I' + id;
			//else if(code)id = '0C' + code;
			//else return {errors: ['ID is not defined']}
			//return this.a.apiQuery(context, 'get', `countries/${id}/`, null)
		  //},
	  },
	  
	  measure_units: {
		  fetchList: (context, {start, maxcnt, order, get_total}) => {
			let data = {limit_num: maxcnt}
			if(order)data['order'] = order;
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			
			return this.a.apiQuery(context, 'get', `measure_units/`, data)
		  },
		  
		  show: (context, id = null, {code} = {}) => {
			if(id)id = 'I' + id;
			else if(code)id = '0C' + code;
			else return {errors: ['ID is not defined']}
			return this.a.apiQuery(context, 'get', `measurements/${id}/`, null)
		  },
	  },
  },
  
  
  seller: {
	  prodgroups: {
		  fetchList: (context, seller_id = null, parent_group_id = null, depth = null) => {
			return this.a.apiQuery(context, 'get', `sellers/${seller_id}/prodgroups`, {parent_group_id, depth})
		  },
		  
		  createNew: (context, list, seller_id = null) => {
			return this.a.apiQuery(context, 'post', `sellers/${seller_id}/prodgroups/`, null, {list})
		  },
		  
		  update: (context, changes, seller_id = null) => {
			return this.a.apiQuery(context, 'post', `sellers/${seller_id}/prodgroups/update`, null, {changes})
		  },
		  
		  destroy: (context, id, data, seller_id = null) => {
			return this.a.apiQuery(context, 'delete', `sellers/${seller_id}/prodgroups/${id}/`, null, data, {notify_on_error: false})
		  },
		  
		  fetchParents: (context, id, seller_id = null) => {
			return this.a.apiQuery(context, 'post', `sellers/${seller_id}/prodgroups/${id}/parents`, null, null, {notify_on_error: false})
		  },
		  
		  fetchParentsTree: (context, id, seller_id = null) => {
			return this.a.apiQuery(context, 'post', `sellers/${seller_id}/prodgroups/${id}/parents_tree`, null, null, {notify_on_error: false})
		  },
	  },
	  
	  products: {
		  fetchList: (context, {start, maxcnt, order, get_total, subnode_id, params}) => {
			if(typeof subnode_id == 'undefined')return {errors: null};
			
			let data = {limit_num: maxcnt}

			if(order)data['order'] = order;
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			if(params.include_subgroups)data['include_subgroups'] = params.include_subgroups;
			
			return this.a.apiQuery(context, 'get', `sellers/${params.seller_id}/prodgroups/${subnode_id}/products/`, data)
		  },
		  
		  show: (context, id, {seller_id}) => {
			if(typeof seller_id == 'undefined')seller_id = null;
			return this.a.apiQuery(context, 'get', `sellers/${seller_id}/products/${id}/`, null, null, {notify_on_error: false})
		  },
		  
		  createNew: (context, list, {seller_id, group_id}) => {
			return this.a.apiQuery(context, 'post', `sellers/${seller_id}/prodgroups/${group_id}/products/`, null, {list})
		  },
		  
		  update: (context, id, {seller_id, group_id, changes}) => {
			if(!group_id || !changes)return;
			if(typeof seller_id == 'undefined')seller_id = null;
			return this.a.apiQuery(context, 'patch', `sellers/${seller_id}/prodgroups/${group_id}/products/${id}/`, null, {changes})
		  },
		  
		  destroy: (context, id, data, group_id, seller_id = null) => {
			return this.a.apiQuery(context, 'delete', `sellers/${seller_id}/prodgroups/${group_id}/products/${id}/`, null, data, {notify_on_error: false})
		  },
		  
		  fetchImages: (context, id, {seller_id, id_array}) => {
			if(typeof seller_id == 'undefined')seller_id = null;
			if((typeof id_array == 'undefined') && (typeof id == 'number'))id_array = [id];
			
			return this.a.apiQuery(context, 'post', `sellers/${seller_id}/products/images`, null, {id_array}, {notify_on_error: false})
		  },
		  
		  fetchSuppliers: (context, {start, maxcnt, order, get_total, subnode_id, params}) => {
			let data = {limit_num: maxcnt}
			
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			
			return this.a.apiQuery(context, 'post', `sellers/${params.seller_id}/products/${subnode_id}/suppliers`, null, data, {notify_on_error: false})
		  },
		  
		  fetchInStock: (context, {start, maxcnt, order, get_total, subnode_id, params}) => {
			let data = {limit_num: maxcnt}
			
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			
			return this.a.apiQuery(context, 'post', `sellers/${params.seller_id}/products/${subnode_id}/instock`, null, data, {notify_on_error: false})
		  },
		  
		  fetchPricingMath: (context, {start, maxcnt, order, get_total, subnode_id, params}) => {
			let data = {limit_num: maxcnt}
			
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			
			return this.a.apiQuery(context, 'post', `sellers/${params.seller_id}/products/${subnode_id}/pricing_math`, null, data, {notify_on_error: false})
		  },
		  
		  fetchFixedPrices: (context, {start, maxcnt, order, get_total, subnode_id, params}) => {
			let data = {limit_num: maxcnt}
			
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			
			return this.a.apiQuery(context, 'post', `sellers/${params.seller_id}/products/${subnode_id}/fixed_prices`, null, data, {notify_on_error: false})
		  },
	  },
	  
	  brands: {
		  fetchList: (context, {start, maxcnt, order, get_total, params}) => {
			let data = {limit_num: maxcnt}
			if(order)data['order'] = order;
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			
			return this.a.apiQuery(context, 'get', `sellers/${params.seller_id}/brands/`, data)
		  },
		  
		  createNew: (context, list, seller_id = null) => {
			return this.a.apiQuery(context, 'post', `sellers/${seller_id}/brands/`, null, {list})
		  },
		  
		  show: (context, id, {seller_id}) => {
			if(typeof seller_id == 'undefined')seller_id = null;
			return this.a.apiQuery(context, 'get', `sellers/${seller_id}/brands/${id}/`, null, null, {notify_on_error: false})
		  },
		  
		  destroy: (context, id, data, seller_id = null) => {
			return this.a.apiQuery(context, 'delete', `sellers/${seller_id}/brands/${id}/`, null, data, {notify_on_error: false})
		  },
	  },
	  
	  pricing_prices: {
		  fetchList: (context, {start, maxcnt, order, get_total, subnode_id, params}) => {
			let data = {limit_num: maxcnt}

			if(order)data['order'] = order;
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			
			return this.a.apiQuery(context, 'get', `sellers/${params.seller_id}/pricing_prices/`, data, null, {notify_on_error: false})
		  },
		  
		  getInfo: (context, id, {seller_id, id_array}) => {
			if(typeof seller_id == 'undefined')seller_id = null;
			return this.a.apiQuery(context, 'post', `sellers/${seller_id}/pricing_prices/info`, null, {id_array}, {notify_on_error: false})
		  },
	  },
	  
	  pricing_rules: {
		  fetchList: (context, {start, maxcnt, order, get_total, subnode_id, params}) => {
			let data = {limit_num: maxcnt}

			if(order)data['order'] = order;
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			
			return this.a.apiQuery(context, 'get', `sellers/${params.seller_id}/pricing_rules/`, data, null, {notify_on_error: false})
		  },
		  
		  getInfo: (context, id, {seller_id, id_array}) => {
			if(typeof seller_id == 'undefined')seller_id = null;
			return this.a.apiQuery(context, 'post', `sellers/${seller_id}/pricing_rules/info`, null, {id_array}, {notify_on_error: false})
		  },
	  },
	  
	  pricing_fixed: {
		  fetchList: (context, {start, maxcnt, order, get_total, subnode_id, params}) => {
			let data = {limit_num: maxcnt}

			if(order)data['order'] = order;
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			
			return this.a.apiQuery(context, 'get', `sellers/${params.seller_id}/pricing_fixed/`, data, null, {notify_on_error: false})
		  },
	  },
	  
	  pricing_maths: {
		  fetchList: (context, {start, maxcnt, order, get_total, subnode_id, params}) => {
			let data = {limit_num: maxcnt}

			if(order)data['order'] = order;
			if(start)data['start_point'] = start;
			if(get_total)data['get_total'] = get_total;
			if(!params)params = {seller_id: null}
			
			return this.a.apiQuery(context, 'get', `sellers/${params.seller_id}/pricing_maths/`, data, null, {notify_on_error: false})
		  },
	  },
	  
	  
  },
})