import Auth from 'auth/auth'

const state = {
	UserToken: {
		token: null,
		expires_at: null,
		timediff: 0
	},
	
	UserAuthorized: false
}


const mutations = {
	USER_TOKEN_SET(state, response_data){
		state.UserToken.token = response_data.token
		state.UserToken.expires_at = response_data.expires_at
		state.UserToken.timediff = response_data.time_now - Math.floor(Date.now() / 1000)
		if(!state.UserAuthorized && state.UserToken.token){state.UserAuthorized = true}
	},

	USER_TOKEN_STORE(state, response_data){
		localStorage.setItem("UserToken", state.UserToken.token)
		localStorage.setItem("UserToken_expires", state.UserToken.expires_at)
		localStorage.setItem("UserToken_timediff", state.UserToken.timediff)
	},
	
	USER_TOKEN_CLEAR(state){
		state.UserToken.token = null
		state.UserToken.expires_at = null
		state.UserToken.timediff = 0
	},
	
	USER_TOKEN_LOAD(state){
		let n = localStorage.getItem("UserToken"); if(!n || (n == 'null')){n = null;}
		state.UserToken.token = n
		
		n = localStorage.getItem("UserToken_expires"); if(!n || (n == 'null')){n = null;}
		state.UserToken.expires_at = n
		
		n = localStorage.getItem("UserToken_timediff"); if(!n || (n == 'null')){n = 0;}
		state.UserToken.timediff = n
		
		if(!state.UserAuthorized && state.UserToken.token){state.UserAuthorized = true}
	},
}


const actions = {

  async fetchUserToken (context){
	let response = await Auth.fetchLoginCheck(context)
	
	if(response && response.result && response.result.data){
		if(response.result.data.token){
			context.commit('USER_TOKEN_SET', response.result.data)
			context.commit('USER_TOKEN_STORE', response.result.data)
		}
		else if(response.result.data.signed_in === true){
			// Fetch User Token from Auth Service
			return await this.dispatch('fetchTokenWithUserScope')
		}
		else {
			// Alert: You are not Logged in! Redirect...
		}
	}
	else {
		// Alert: Error during Token search!
	}
  },
  
  
  loadUserToken (context){
	// context.commit('USER_TOKEN_CLEAR'); context.commit('USER_TOKEN_STORE');
	context.commit('USER_TOKEN_LOAD')
	
	// Verify the Main User Token is not expired
	if(state.UserToken.token && state.UserToken.expires_at){
		if((Math.floor(Date.now() / 1000) + (state.UserToken.timediff ? state.UserToken.timediff : 0)) >= state.UserToken.expires_at){
			context.commit('USER_TOKEN_CLEAR'); context.commit('USER_TOKEN_STORE');
		}
	}
  },
  
  
  async getActionScopesRequired (context, {method, url, token_mandatory, token_now, repeated}){
	let response, token_data
	
	response = await this.dispatch('fetchApiScopesRequired', {method, url, user_token: (token_mandatory ? state.UserToken.token : null)})
	console.log('API Scopes Required:', response); 
	if(!response.scopes){
		if(response.bad_token){
			if(!token_now){
				if(token_mandatory){
					// Update user token
					response = await this.dispatch('fetchTokenWithUserScope')
					if(response && response.cancel){return response}
				}
				else if(!repeated){
					// Try to retrieve user token
					response = await this.dispatch('fetchUserToken')
					if(response && response.cancel){return response}
					
					response = await this.dispatch('getActionScopesRequired', {method, url, token_mandatory, token_now: true, repeated: true})
				}
			}
		}
		else if(response.forbidden){
			// Alert the action is forbidden
		}
	}
	
	return response
  },
  
  
  async getActionToken (context, {method, url, mandatory, skip_stored, with_user_token}){
	let vApp = context.rootState.App
	let response = null, token_data, token_now = false
	
	// Check for Main User Token
	await this.dispatch('loadUserToken')
	
	// Request for new Main User Token if a Token usage is mandatory and no user token exist
	if(mandatory && !state.UserToken.token){
		await this.dispatch('fetchUserToken')
		token_now = true
	}
	
	// Stop if unable to get user token
	if(!state.UserToken.token){return {token: null}}
	
	if(with_user_token && !skip_stored){return {token: state.UserToken.token}}
	
	// Find stored Token for URL template and method
	if(!skip_stored){
		token_data = await this.dispatch('storageLookupTokenForUrl', {method, url})
		if(token_data && token_data.token){
			return {token: token_data.token, stored_token: true}
		}
	}
	
	// Query for Required Token Scopes using Main User Token
	response = await this.dispatch('getActionScopesRequired', {method, url, token_mandatory: mandatory, token_now, repeated: false})
	if(response){
		
		if(response.scopes){
			if(!skip_stored){
				// Search for stored token with scopes required
				token_data = await this.dispatch('storageLookupTokenWithScopes', response.scopes)
				if(token_data && token_data.token){
					await this.dispatch('storeToken', {method, url, token_data})
					return {token: token_data.token}
				}
			}
			
			// Query Auth Service for Token with Scopes Required
			response = await this.dispatch('fetchTokenWithScopes', {scopes_required: response.scopes})
			if(response && response.token_data && response.token_data.token){
				await this.dispatch('storeToken', {method, url, token_data: response.token_data})
				return {token: response.token_data.token}
			}
		}
		else if(response.cancel){
			return response
		}
	}
	
	return {token: state.UserToken.token}
  },
  
  
  async storeToken (context, {method, url, token_data}) {
	let storage = 'local'
	
	if(token_data.scopes){
		if(token_data.scopes.includes('write') || token_data.scopes.includes('import') || token_data.scopes.includes('export')){
			storage = 'session'
		}
	}
	
	let stored_key = await this.dispatch('storageSaveToken', {storage, data: {
		scope: token_data.scope,
		token: token_data.token,
		expires_at: token_data.expires_at,
		timediff: token_data.time_now - Math.floor(Date.now() / 1000)
	}})
	
	if(stored_key){
		this.dispatch('storageSaveTokenUrlMethod', {url, method, token_item: stored_key, token_storage: storage})
	}
  },
  
  
  async fetchApiScopesRequired (context, {method, url, user_token, repeated}) {
	let n = url.lastIndexOf('/'); if(n <= 0){return null;}
	let req_action = url.substr(n+1)
	let url_parent = url.substr(0,n)
	let response
	
	if(req_action == ''){req_action = 'index';}
	if(['index', 'show', 'create', 'new', 'edit', 'update', 'destroy'].includes(req_action)){
		url = url_parent
	}
	//else {
	//	n = url.lastIndexOf('/')
	//	if(n > 0){
	//		let root_dir = url.substr(n+1)
	//		if(!isNaN(root_dir) || !isNaN(root_dir.charAt(0))){
	//			url = url_parent
	//		}
	//	}
	//}
	
	response = await context.rootState.App.$api.fetchScopesRequired(context, {method, url, token: user_token, req_action})
	
	if(response.result && response.result.data){
		if(typeof response.result.data.scopes == 'string'){
			return {scopes: response.result.data.scopes}
		} else {
			return {scopes: response.result.data.scopes[req_action]}
		}
	}
	else if(response.errors){
		if(response.errors[0] && response.errors[0].response){
			switch(response.errors[0].response.status){
				case 404: // not_found
					// Try again one time with parent dir
					if(!repeated)return (await this.dispatch('fetchApiScopesRequired', {repeated: true, method, url: url_parent, user_token}));
					break;
				case 400: // bad_request (the token is corrupted or expired)
				case 401: // unauthorized (the token is not authorized)
					return {bad_token: true}
					break;
				case 402: // payment required
					return {not_paid: true}
					break;
				case 403: // forbidden (the scopes provided aren't enough or user has no rights)
					return {forbidden: true}
					break;
			}
		}
	}
	return {scopes: null}
  },
  
  
  async fetchTokenWithScopes (context, {scopes_required, repeated} = {}) {
	let response

	// Request backend for URI to take Token from Auth Service
	if(scopes_required){
		response = await Auth.fetchScopesTokenUri(context, {user_token: state.UserToken.token,  scopes_required})
	} else {
		response = await Auth.fetchUserTokenUri(context) 
	}
	
	if(response && response.result && response.result.data){
		if(response.result.data.redirect_to){
			response = await Auth.fetchTokenFromAuth(context, response.result.data.redirect_to) // Authorize on Auth Service and Fetch Token with scopes required
			if(response && response.result){
				if(response.result.data && response.result.data.token){
					return {token_data: response.result.data}
				} else {
					// Alert: You are not allowed to this action! Please try to logout and login again.
					if(response.result.data && response.result.data.redirect_to_sign_in){
						if(await context.rootState.App.$confirmDialog({
							title: 'Нет доступа',
							content: 'Для продолжения работы необходимо Войти в Личный кабинет под Вашей учётной записью.'
						})){
							window.location = response.result.data.redirect_to_sign_in
						}
					} else {
						context.rootState.App.$messageBox('Проверка ваших прав доступа не пройдена!')
					}
					return {cancel: true}
				}
			} else {
				// Warn: Some errors during Auth Service request
				context.rootState.App.$messageBox('Во время проверки прав доступа произошла ошибка. Попробуйте повторить операцию.')
				return {cancel: true}
			}
		} else {
			// Alert: You are not allowed to this action! Please try to logout and login again.
			console.error('You are not allowed to query this scopes!')
		}
	} else {
		// Alert: Error during Token fetching! if(scopes_required == null)
		if(response.errors && response.errors[0] && response.errors[0].response){
			if(response.errors[0].response.status == 401 || response.errors[0].response.status == 403){
				console.error('You are not signed in!', response)
				if(!repeated){
					console.log('Query for login')
					
					await Auth.LogoutAndRedirectToSignin(context)
					await context.rootState.App.$messageBox('Необходимо Войти в Личный кабинет')
					return {cancel: true}
					
					response = await this.dispatch('askUserForCredentials')
					if(!response){return null}
					
					if(response.success){
						return await this.dispatch('fetchTokenWithScopes', {scopes_required, repeated: true});
					} else if(response.cancel){
						return {cancel: true};
					} else {
						return null;
					}
				}
			}
		}
		console.error('Error during Token fetching!', response)
	}
	return null
  },
  
  
  async fetchTokenWithUserScope (context){
	let response
	if(response = await this.dispatch('fetchTokenWithScopes')){
		if(response.token_data){
			context.commit('USER_TOKEN_SET', response.token_data)
			context.commit('USER_TOKEN_STORE', response.token_data)
		} else if(response.cancel){
			return {cancel: true}
		}
	}
	return response
  },
  
  
  async askUserForCredentials (context){
	  let login

	  for(let i = 0; i < 3; i++){
		login = await context.rootState.App.$loginDialog()
		if(!login){return {cancel: true}}
		console.log('login:', login)
		
		// Logout from this site on this browser and Login to Auth service
		response = await Auth.makeSignin(context) // Authorize on Auth Service and Fetch Token with scopes required
		console.log('makeSignin:', response)
		// try to auth
		// ask again or return
	  }
  },
  
}


export default {
  state,
  mutations,
  actions,
}