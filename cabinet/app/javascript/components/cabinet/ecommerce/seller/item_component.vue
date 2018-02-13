<template lang='pug'>
  div
    <router-view></router-view>
</template>

<script>

export default {
  data (){return {
	  data: null,
  }},
  props: ['seller_id'],

  methods: {
	storeSellerId (){
		this.$store.dispatch('setSellerId', this.seller_id)
	},
  },
  
  
  created (){
	  this.storeSellerId()
  },
  
  
  watch: {
	  '$route' (to, from){
		  this.storeSellerId()
		  //console.log('seller route to', to)
	  },
  },
  
  
  computed: {
    //title (){return this.$store.state.news.title},
  },

}
</script>