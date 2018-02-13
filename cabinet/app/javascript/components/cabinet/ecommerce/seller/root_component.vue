<template>
  <router-view></router-view>
</template>

<script>

export default {
  data (){return {data: null}},
  
  methods: {
    
    // showSellerGroups (){
    //   this.$store.dispatch('fillSellerProductsGroups')
    // },
  },
  
  
  created (){
	
  },
  
  
  watch: {
	//'$route' (to, from){
	//	this.$store.cabinet.ecommerce.dispatch('setActiveCustomerId', {id: this.$route.params.seller_id})
	//	console.log('seller_id', this.$route.params.seller_id)
	//}
  },
  
  
  computed: {
    //title (){return this.$store.state.news.title},
  },
  
}
</script>