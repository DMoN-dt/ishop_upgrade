<template lang='pug'>
  div.user-cabinet.authorized(v-if="user_authorized")
    <breadcrumbs></breadcrumbs>
    
    div.cabinet-mainpage(v-if="stored_user_allowed")
      <router-view></router-view>

    div.cabinet-mainpage(v-else)
      p Доступ в Личный кабинет запрещён!

  div.user-cabinet.unauthorized(v-else)
    p Нужно Войти.
</template>

<script>

export default {
  data (){return {
	  authorized: false,
	  allowed: false,
  }},
  
  methods: {
    // showSellerGroups (){
    //   this.$store.dispatch('fillSellerProductsGroups')
    // },
  },
  
  
  created (){
      // this.showSellerGroups()
  },
  
  
  watch: {
      // '$route': 'showSellerGroups'
  },
  
  
  computed: {
    //title (){return this.$store.state.news.title},
    async user_authorized (){
		if(this.$store.state.tokens.UserAuthorized){
			if(!this.authorized){
				await this.$store.dispatch('loadCabinetGeneralInfo')
				this.authorized = true
			}
			return true
		
		} else {
			if(this.authorized){
				await this.$store.dispatch('clearCabinetGeneralInfo')
				this.authorized = false
			}
			return false
		}
    },
	
	user_allowed (){
		try {
			return this.$store.state.cabinet.CabinetGeneralInfo.user.is_allowed
		} catch (e){return false}
	},
	
	stored_user_allowed (){
		if(!this.allowed)this.allowed = this.user_allowed;
		return this.allowed
	},
  },
}
</script>