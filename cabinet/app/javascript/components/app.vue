<template>
  <div id="app">
    <notifications group="main" />
	<dialogs-wrapper tag="div" transition-name="fade"></dialogs-wrapper>
    <router-view></router-view>
  </div>
</template>

<script>
export default {
  name: 'app',
  
  data (){return {
    csrf_Token: '',
  }},
  
  methods: {
    setCsrfTokenFromMeta (){
	  this.csrf_Token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
	  return this.csrf_Token
	},
	
	getCsrfToken (){
		if(this.csrf_Token){return this.csrf_Token;}
		else return this.setCsrfTokenFromMeta();
	},
	
	async getUserToken (){
		await this.$store.dispatch('loadUserToken')
		if(!this.$store.state.tokens.UserToken.token){
			await this.$store.dispatch('fetchUserToken')
		}
	}
  },
  
  created (){
	this.$store.state.App = this
	//if(!(this.$http.defaults.headers.common['X-CSRF-TOKEN'] = this.setCsrfTokenFromMeta())){
	if(!this.setCsrfTokenFromMeta()){
		console.error('CSRF token not found !')
	}
	this.getUserToken()
  },
  
  computed: {
	  user_authorized (){
		  return (this.$store.state.tokens.UserToken.token ? true : false)
	  }
  }
}
</script>