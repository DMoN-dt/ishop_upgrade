<template lang='pug'>
  div
    div
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
      // this.showSellerGroups()
  },
  
  
  watch: {
      // '$route': 'showSellerGroups'
  },
  
  
  computed: {
    //title (){return this.$store.state.news.title},
  },
}
</script>