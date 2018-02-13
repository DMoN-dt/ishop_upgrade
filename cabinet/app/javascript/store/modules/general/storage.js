const state = {
    data: null,
	data_success: false,
}


const mutations = {
	LOCAL_SAVE(state, data){
		
	},
	
	SESSION_SAVE(state, data){
		
	},
}


const actions = {
  getItem (context, {storage, key}){
	if(storage == 'local'){return localStorage.getItem(key);}
	else return sessionStorage.getItem(key);
  },
  
  
  getLocalItem (context, key){
	return localStorage.getItem(key);
  },
  
  
  getSessionItem (context, key){
	  
  },
  
  
  saveItem (context, {storage, key, value}){
	
  },
  
  
  saveLocalItem (context, {key, value}){
	
  },
  
  
  saveSessionItem (context, {key, value}){
	
  },
  
  
  storageSaveToken (context, {storage, data}){
	let stg, kname
	
	this.dispatch('clearExpiredTokens', storage)
	
	if(storage == 'local'){stg = localStorage;}
	else {stg = sessionStorage;}
	
	kname = 'tkn_' + Math.floor(Date.now() / 1000)
	stg.setItem(kname, JSON.stringify(data))
	
	return kname
  },
  
  
  clearExpiredTokens (context, storage){
	let stg, kname, tkn, expired = [], tnow = Math.floor(Date.now() / 1000)
	
	if(storage == 'local'){stg = localStorage;}
	else {stg = sessionStorage;}
	
	for(let i=0; i < stg.length; i++){
	  // console.log("Ключ: " + stg.key(i) + "; Значение: " + stg.getItem(stg.key(i)))
	  if((kname = stg.key(i)).includes('tkn_')){
		  tkn = JSON.parse(stg.getItem(kname))
		  if(tkn.expires_at <= (tnow + tkn.timediff)){expired.push(kname);}
	  }
	}
	
	expired.forEach(function(key){stg.removeItem(key);})
  },
  
  
  storageSaveTokenUrlMethod (context, {method, url, token_item, token_storage}){
	let kname
	url = url.replace(/\w+\/(\d+([\d\w.:-]+)?|null)/g, '$&?ID?').replace(/\/(\d+([\d\w.:-]+)?|null)(\?ID\?)/g, '/?ID?')
	
	for(let i=0; i < localStorage.length; i++){
		if((kname = localStorage.key(i)).includes('urlm_')){
		  let urlm = JSON.parse(localStorage.getItem(kname))
		  if((urlm.u == url) && (urlm.m == method)){
			 urlm.tkn = token_item
			 urlm.s = token_storage
			 urlm.upd++
			 localStorage.setItem(kname, JSON.stringify(urlm))
			 return
		  }
		}
	}
	
	localStorage.setItem('urlm_' + Math.floor(Date.now() / 1000), JSON.stringify({u: url, m: method, tkn: token_item, s: token_storage, upd: 1}))
  },
  
  
  async storageLookupTokenForUrl (context, {method, url}){
	let kname
	url = url.replace(/\w+\/(\d+([\d\w.:-]+)?|null)/g, '$&?ID?').replace(/\/(\d+([\d\w.:-]+)?|null)(\?ID\?)/g, '/?ID?')
	
	for(let i=0; i < localStorage.length; i++){
		if((kname = localStorage.key(i)).includes('urlm_')){
		  let urlm = JSON.parse(localStorage.getItem(kname))
		  if((urlm.u == url) && (urlm.m == method)){
			 let token_item = await this.dispatch('getItem', {storage: urlm.s, key: urlm.tkn})
			 if(token_item){
				 token_item = JSON.parse(token_item)
				 if(token_item && token_item.token){
					 if(token_item.expires_at){
						 if((Math.floor(Date.now() / 1000) + (token_item.timediff ? token_item.timediff : 0)) < token_item.expires_at)return token_item;
					 }
					 else return token_item;
				 }
			 }
			 return null;
		  }
		}
	}
	
	return null
  },
   
  
  storageLookupTokenWithScopes (context, scopes_str){
	let kname, tkn, tnow = Math.floor(Date.now() / 1000), scopes_required = scopes_str.split(' '), result = null, expired = []
	let storages = [localStorage, sessionStorage]
	
	storages.forEach(function(stg){
		if(!result || result.expired){
			for(let i=0; i < stg.length; i++){
				if((kname = stg.key(i)).includes('tkn_')){
					tkn = JSON.parse(stg.getItem(kname))
					
					let tkn_scopes = tkn.scope.split(' ')
					if(scopes_required.every(function(currentValue){return tkn_scopes.includes(currentValue);})){
						result = tkn;
						
						if(tkn.expires_at){
							if((Math.floor(Date.now() / 1000) + (tkn.timediff ? tkn.timediff : 0)) < tkn.expires_at){result.expired = false; break;}
							else result.expired = true;
						} else {result.expired = false; break}
					}
				}
			}
			
			if(expired.length > 0){
				expired.forEach(function(key){stg.removeItem(key);})
				expired = []
			}
		}
	})
	
	return ((result && result.expired) ? null : result)
  },
  
}


export default {
  data (){return {data: null}},
  state,
  mutations,
  actions,
}