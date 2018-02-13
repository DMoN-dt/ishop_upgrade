<template>
  <listview
    :data="data" :data_from="data_from" @fetchMoreData="onFetchMoreData" @item-focus="onItemFocus"
    :dataViewFields="list_fields"
    :dataTotalCount="totalCount"
    :variantsPerPage="variantsPerPage" :currentPerPage="currentPerPage" :paginateLink="true"></listview>
</template>

<script>
import Vue from 'vue'
import ListView from 'components/general/list-view/listview'

export default {
  name: 'products-list',
  props: {
    data: {type: Array},
	data_from: {type: Number},
    totalCount: {type: Number},
	variantsPerPage: {type: Array, default: () => {[25,50,100]}},
	currentPerPage: {type: Number, default: 25},
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
  
  
  //created (){
  //},
  
  
  computed: {
	list_fields (){
		return {
			'id': 'ID',
			'name': 'Наименование',
			'prod_code': 'Код продукта',
			'prod_artikul': 'Артикул товара',
			
			'available_count': 'Доступно',
			'reserved_count': 'В резерве',
			'avail_suppliers_count': 'У поставщиков',
			'lot_in_stock_count': 'В наличии',
			
			'updated_at': 'Изменено',
			'is_popular': {class:[{val: true, name: 'prod-popular'}]},
			'bactive': {class:[{val_not: true, name: 'prod-inactive'}]},
		}
	},
  },
  
  //watch: {
	  //'$route' (to, from){
	  //}
  //}
}

</script>