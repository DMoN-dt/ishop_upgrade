<template>
  <ol class="breadcrumb cabinet-breadcrumb" v-if="$breadcrumbs.length">
    <li v-for="(crumb, ii) in bcrumbs.length" v-if="!bcrumbs[ii].hidden" class="breadcrumb-item">
      <router-link v-if="bcrumbs[ii].prop" :to="bcrumbs[ii].prop">{{ bcrumbs[ii].title }}</router-link>
      <span v-else>{{ bcrumbs[ii].title }}</span>
    </li>
  </ol>
</template>

<script>
import Vue from 'vue'

function getMatchedRoutes (routes) {
  // Convert to an array if Vue 1.x
  if (parseFloat(Vue.version) < 2) {
    routes = (Object.keys(routes)).filter(function (key) {
      return !isNaN(key)
    }).map(function (key) {
      return routes[key]
    })
  }

  return routes
}

// Add the $breadcrumbs property to the Vue instance
Object.defineProperty(Vue.prototype, '$breadcrumbs', {
  get: function get () {
    var crumbs = []

    var matched = getMatchedRoutes(this.$route.matched)

    matched.forEach(function (route) {
      // Backwards compatibility
      var hasBreadcrumb = (parseFloat(Vue.version) < 2)
        ? route.handler && route.handler.breadcrumb
        : route.meta && route.meta.breadcrumb
        
      if (hasBreadcrumb) {
        crumbs.push(route)
      }
    })
      
    return crumbs
  }
})

export default {
  data (){return {bcrumbs: []}},
  
  created (){
	  this.linksBuild()
  },
  
  methods: {
    linksBuild (){
		this.bcrumbs = []
		let i = 0
		this.$breadcrumbs.forEach(function(crumb){
			this.bcrumbs[i] = {prop: this.linkProp(crumb), hidden: this.isHidden(crumb)}
			this.bcrumbs[i].title = this.linkTitle(crumb, i)
			i++
		}, this)
	},
	
	linkProp (crumb) {
      // If it's a named route, we'll base the route off of that instead
      if(crumb.name || (crumb.handler && crumb.handler.name)) {
		return {
          name: crumb.name || crumb.handler.name,
          params: this.$route.params
        }
      }
	  
	  let path = crumb.path
	  Object.keys(this.$route.params).map(function(key, index){
		path = path.replace(new RegExp(':' + key, 'g'), this[key]);
	  }, this.$route.params);
	  
	  if(path[path.length-1] != '/')path += '/';
	  if((path == this.$route.path) || (path == (this.$route.path + '/')))return null;
	  
	  return {
        path,
        //params: this.$route.params
      }
    },
	
	linkTitle (crumb_route, crumb_idx){
	  if(crumb_route.meta.breadcrumb.titleGetter){
	  	let title_getter
		this.$store.dispatch(crumb_route.meta.breadcrumb.titleGetter, {callback: function(res, {_this, crumb_idx}){
			if(!res)res = _this.loadingText(crumb_route)
			_this.bcrumbs[crumb_idx].title = res
			Vue.set(_this.bcrumbs, crumb_idx, _this.bcrumbs[crumb_idx])
		}, params: {_this: this, crumb_idx} })
		
	  	return this.loadingText(crumb_route)
	  }
	  return (crumb_route.meta.breadcrumb.textI18n ? this.$t(crumb_route.meta.breadcrumb.textI18n) : crumb_route.meta.breadcrumb.text)
	},
    
    loadingText(crumb_route) {
      let text
	  const bcb = crumb_route.meta.breadcrumb
	  
	  if(bcb.textLoadingI18n){
		  if(typeof bcb.textLoadingI18n == 'string')text = this.$t(bcb.textLoadingI18n)
		  else text = this.$t(bcb.textLoadingI18n.t, {id: bcb.textLoadingI18n.id});
	  }
	  if(!text)text = (bcb.textLoading ? bcb.textLoading : 'Загрузка...');

      return text
    },
	
	isHidden(crumb_route){
		return (crumb_route.meta.breadcrumb.hideOnEstore)
	},
  },
  
  watch: {
	  '$route' (to, from){
		  this.linksBuild()
	  },
  }
}
</script>