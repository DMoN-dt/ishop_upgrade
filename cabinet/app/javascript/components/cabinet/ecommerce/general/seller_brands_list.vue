<template>
  <listview
    :data="data" :data_from="data_from" @fetchMoreData="onFetchMoreData" @item-focus="onItemFocus"
    :dataViewFields="listFields"
    :dataTotalCount="totalCount"
    :variantsPerPage="variantsPerPage" :currentPerPage="currentPerPage" :paginateLink="false"></listview>
</template>

<script>
import ListView from 'components/general/list-view/listview'

export default {
  name: 'list',
  props: {
    data: {type: Array},
	data_from: {type: Number},
    totalCount: {type: Number},
	variantsPerPage: {type: Array, default: () => {[25,50,100]}},
	currentPerPage: {type: Number, default: 25},
	listFields:  {type: Object, default: null},
  },
  
  data (){return {}},
  
  components: {
	'listview': ListView
  },

  methods: {
    onFetchMoreData ({start, length, total_unknown}){
		this.$emit('fetchMoreData', {start, length, total_unknown})
	},
	
	onItemFocus (node, item){
		this.$emit('item-focus', item)
	},

  },
}
</script>