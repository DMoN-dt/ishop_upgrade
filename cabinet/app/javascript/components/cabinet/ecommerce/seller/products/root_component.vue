<template>
  <router-view></router-view>
</template>

<script>

export default {
  data (){return {data: null}},
  props: ['prodgroup_id'],
  
  methods: {
	storeProductsGroupId (){
		this.$store.dispatch('DataArray_setDefaultSubNodeId', {node: 'products', id: this.prodgroup_id})
	},
  },
  
  
  created (){
	  this.storeProductsGroupId()
  },
  
  
  watch: {
	  '$route' (to, from){
		  this.storeProductsGroupId()
		  // console.log('products route to', to)
	  },
  },
  
  
  computed: {
    //title (){return this.$store.state.news.title},
  },
  
}
</script>