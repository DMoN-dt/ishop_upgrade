<template>
  <div v-if="!isNaN(totalPages) && (totalPages > 0)" :class="classes">
	<a v-if="paginateLink && (currentPage != startPage) && (startPage != 1)" v-on:click.prevent="show_page(1)" :href="page_link_hash + '1' + page_items_count_hash" class="pag_el">1</a>
	<a v-if="paginateLink && (currentPage != startPage) && (startPage > 2)" v-on:click.prevent="show_page(((currentPage - numbersCount) < 1) ? 2 : (currentPage - numbersCount))" :href="page_link_hash + (((currentPage - numbersCount) < 1) ? 2 : (currentPage - numbersCount)) + page_items_count_hash" class="pag_el">..</a>
	
	<span v-if="!paginateLink && (currentPage != startPage) && (startPage != 1)" v-on:click.prevent="show_page(1)" class="pag_el">1</span>
	<span v-if="!paginateLink && (currentPage != startPage) && (startPage > 2)" v-on:click.prevent="show_page(((currentPage - numbersCount) < 1) ? 2 : (currentPage - numbersCount))" class="pag_el">..</span>
	
	<span v-for="sp in pages_list">
      <span v-if="Math.abs(sp - currentPage) <= 5">
        <span v-if="sp == currentPage" class="pag_el"><b>{{sp}}</b></span>
        <a v-else-if="paginateLink" v-on:click.prevent="show_page(sp)" :href="page_link_hash + sp + page_items_count_hash" class="pag_el">{{sp}}</a>
        <span v-else v-on:click.prevent="show_page(sp)" class="pag_el">{{sp}}</span>
      </span>
    </span>
	
	<a v-if="paginateLink && (currentPage != endPage) && (endPage != totalPages) && (endPage < (totalPages - 1))" v-on:click.prevent="show_page(((endPage + 1) > totalPages) ? totalPages : (endPage + 1))" :href="page_link_hash + (((endPage + 1) > totalPages) ? totalPages : (endPage + 1)) + page_items_count_hash" class="pag_el">..</a>
	<a v-if="paginateLink && (currentPage != endPage) && (endPage != totalPages)" v-on:click.prevent="show_page(totalPages)" :href="page_link_hash + totalPages + page_items_count_hash" class="pag_el">{{totalPages}}</a>
  
	<span v-if="!paginateLink && (currentPage != endPage) && (endPage != totalPages) && (endPage < (totalPages - 1))" v-on:click.prevent="show_page(((endPage + 1) > totalPages) ? totalPages : (endPage + 1))" class="pag_el">..</span>
	<span v-if="!paginateLink && (currentPage != endPage) && (endPage != totalPages)" v-on:click.prevent="show_page(totalPages)" class="pag_el">{{totalPages}}</span>
  </div>
  <div v-else :class="classes">
    <span>&nbsp;</span>
  </div>
</template>

<script>
import Vue from 'vue'


export default {
  name: 'PagePagination',
  props: {
	viewMode: {type: Number, default: 0},
	totalPages: {type: Number, default: 0},
	numbersCount: {type: Number, default: 5}, // number of page-links in navigation
	currentPage: {type: Number, default: 1},
	itemsPerPage: {type: Number, default: 1},
	pageHashPretext: {type: String},
	callbackPageNum: {type: String},
	DescNumbering: {type: Boolean, default: false},
	paginateLink: {type: Boolean, default: false},
  },
  
  data (){return {}},
  
  methods: {
	show_page (page_num, per_page_count = this.itemsPerPage, old_page_num = this.currentPage){
		if(page_num < 1)page_num = 1
		if(page_num != old_page_num){
			this.$emit('changePageNum', page_num, per_page_count)
		}
	},
	
	this_page_link_has_pagehash (route = this.$route){
		return (route.hash.substr(0,this.page_link_hash.length) == this.page_link_hash)
	},
	
	this_page_link_pagehash_num (route = this.$route){
		let page_str = route.hash.substr(this.page_link_hash.length)
		if(page_str){
		  let arr = page_str.split('-i')
		  let page_num = Number(arr[0])
		  if(!isNaN(page_num)){
			return {page: page_num, per_page: (arr[1] ? Number(arr[1]) : this.itemsPerPage)}
		  }
		}
		return null
	},
  },
  
  
  created (){
	let pg_num, pg_items
	if(this.paginateLink && this.this_page_link_has_pagehash){
		let arr = this.this_page_link_pagehash_num()
		if(arr){
			pg_num = arr.page
			pg_items = arr.per_page
		}
	}
	
	if(!pg_num){
		pg_num = this.currentPage
		pg_items = this.itemsPerPage
	}
	
	this.show_page(pg_num, pg_items, null)
  },

  
  computed: {
	startPage (){
		if(this.DescNumbering){
			if(this.currentPage + Math.floor(this.numbersCount/2) >= this.totalPages)return this.totalPages;
			else {
				if(this.currentPage + Math.floor(this.numbersCount/2) >= this.numbersCount)return this.currentPage + Math.floor(this.numbersCount/2);
				else {
					if(this.totalPages >= this.numbersCount)return this.numbersCount;
					else return this.totalPages;
				}
			}
		}
		else {
			let sp
			if(this.currentPage > (Math.floor(this.numbersCount/2) + 1) && this.totalPages > this.numbersCount)sp = this.currentPage - Math.floor(this.numbersCount/2);
			else sp = 1;
			
			if(this.currentPage > (this.totalPages - Math.floor(this.numbersCount/2)) || (sp + this.numbersCount-1) > this.totalPages){
				if((this.totalPages - this.numbersCount + 1) >= 1)sp = this.totalPages - this.numbersCount + 1;
			}
			
			return sp
		}
	},
	
	endPage (){
		if(this.DescNumbering){
			if((this.startPage - this.numbersCount) >= 0)return this.startPage - this.numbersCount + 1;
			else return 1;
		}
		else {
			if(this.currentPage <= (this.totalPages - Math.floor(this.numbersCount/2)) && (this.startPage + this.numbersCount-1) <= this.totalPages){
				return this.startPage + this.numbersCount - 1
			}
			else return this.totalPages;
		}
	},
	
	pages_list (){
		let arr = [], start = this.startPage
		while(start < (this.endPage + 1)){arr.push(start++);}
		return arr
	},
	
	page_link_hash (){
		return (this.pageHashPretext ? ('#' + this.pageHashPretext + '-pg') : '#pg')
	},
	
	page_items_count_hash (){
		return '-i' + this.itemsPerPage
	},

	classes () {
      return [
        {'paginate': true},
        {'paginate-default': true},
        {'paginate-invisible': (!this.totalPages || this.totalPages <= 1)},
      ]
    },
  },
  
  watch: {
	  '$route' (to, from){
		  if(this.paginateLink && (to.path == from.path) && (to.hash != from.hash) && to.hash && this.this_page_link_has_pagehash(to)){
			  let arr = this.this_page_link_pagehash_num(to)
			  if(arr){
				  this.show_page(arr.page, arr.per_page);
			  }
		  }
	  }
  },
}

</script>