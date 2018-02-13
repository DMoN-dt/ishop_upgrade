
const _AUTH_SERVICE_ROOT = '//auth.ishop.dev-site.lan'
const _AUTH_LOCAL_ROOT = '/auth/'
const _AUTH_LOCAL_PATH = _AUTH_LOCAL_ROOT


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
  
  async authBackendQuery (context, method, url, url_params, data, {with_token, token, with_csrf, with_credentials, with_json_type, relative_url}) {
	// Default params
	if(typeof with_token   == 'undefined'){with_token = true;}
	if(typeof token        == 'undefined'){token      = 'none';}
	if(typeof with_csrf    == 'undefined'){with_csrf  = true;}
	if(typeof with_credentials == 'undefined'){with_credentials = null;}
	if(typeof with_json_type   == 'undefined'){with_json_type   = true;}
	if(typeof relative_url == 'undefined'){relative_url = true;}
	
	let vApp = context.rootState.App
	
	let axios_prev_cred = false
	let headers = {}
	if(with_token){headers['Authorization'] = 'Bearer ' + token;}
	if(with_csrf ){headers['X-CSRF-TOKEN']  = vApp.getCsrfToken();}
	if(with_json_type){
		headers['Content-Type']  = 'application/json;charset=UTF-8';
		headers['Accept']        = 'application/json';
	}
	if(relative_url){url = `${_AUTH_LOCAL_PATH}${url}`;}
	
	try {
		if(with_credentials){axios_prev_cred = vApp.$http.defaults.withCredentials; vApp.$http.defaults.withCredentials = true;}
		let response = await vApp.$http({method, url, params: url_params, data, headers, with_credentials})
		if(with_credentials && !axios_prev_cred){vApp.$http.defaults.withCredentials = axios_prev_cred;}
		
		console.log('AUTH ANSWER: ', response.data)
		return {result: response.data}
	} catch (e) {
		this.apiOnFailure(vApp, e); //console.log('auth end', url);
		return {errors: [e]}
	}
  },
  
  
  async fetchLoginCheck (context){
	let response = await this.authBackendQuery(context, 'post', 'login_check', null, null, {with_token: false})
	await this.redirectToSignin(context, response)
	return response
  },
  
//  makeSignin: (context) =>  {
//	this.a.authBackendQuery(context, 'delete', 'logout.json', null, null, {with_token: false})
//	return this.a.authBackendQuery(context, 'post', `${_AUTH_SERVICE_ROOT}/users/login`, null, null, {relative_url: false, with_token: false, with_credentials: true})
//  },

  async redirectToSignin (context, response){
	if(response && response.result && response.result.data){
		if(response.result.data.redirect_to){
			console.log('window.location...', response.result.data.redirect_to)
			window.location.href = response.result.data.redirect_to
		}
	}
  },
  
  async LogoutAndRedirectToSignin (context){
	await this.authBackendQuery(context, 'delete', 'logout.json', null, null, {with_token: false})
	let response = await this.authBackendQuery(context, 'post', 'login_to_auth', null, null, {with_token: false})
	await this.redirectToSignin(context, response)
	return response
  },
  
  fetchUserTokenUri: (context) => {
	return this.a.authBackendQuery(context, 'post', 'fetch_token', null, null, {with_token: false})
  },
  
    
  fetchScopesTokenUri: (context, {user_token, scopes_required}) => {
	return this.a.authBackendQuery(context, 'post', 'elevate_priv', null, {req_scopes: scopes_required}, {with_token: true, token: user_token})
  },
  
  fetchTokenFromAuth: (context, uri_with_params) => {
	return this.a.authBackendQuery(context, 'post', uri_with_params, null, null, {relative_url: false, with_token: false, with_credentials: true})
  },
})