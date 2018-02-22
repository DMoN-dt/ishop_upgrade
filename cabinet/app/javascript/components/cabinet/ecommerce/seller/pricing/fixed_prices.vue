<template lang='pug'>
  div.page-block.padding-more.page-pricing-fixed-prices
    h1 {{ $t("seller.pricing.menu_fixed_prices_title") }}
    
    .c-panel
      button.btn.btn-thin3d(v-on:click="") {{ $t("seller.pricing.btn_new_fixed_prices") }}
      | &nbsp;
      button.btn.btn-thin3d(:disabled="!focused_item_valid" @click="mode = 'edit'") {{ $t("buttons.Change") }}
      button.btn.btn-thin3d(:disabled="!focused_item_valid" @click="mode = 'delete'") {{ $t("buttons.Delete") }}
    
    .row
      .col
        listview(
          :data="pricing_list_data" :data_from="pricing_list_start" :dataTotalCount="pricing_list_total"
          :dataViewFields="pricing_list_fields" @fetchMoreData="onFetchMoreData" @item-focus="onItemFocus")


</template>

<script>
import ListView from 'components/general/list-view/listview'


export default {
  data (){return {
	  pricing_list_data: null,
	  pricing_list_total: null,
	  pricing_list_start: null,
	  
	  focusedItem: null,
	  mode: null,
  }},
  
  components: {
	'listview': ListView
  },
  
  
  methods: {
	async onFetchMoreData ({start, length, total_unknown}){
		let list = await this.$store.dispatch('DataArray_getDataSlice', {
			node: 'pricing_fixed_prices', subnode_id: 0,
			params: {seller_id: this.$store.getters.getActiveSellerId},
			start, length, total_unknown, order: ['name asc'],
			api_func_load: 'seller.pricing_fixed.fetchList',
		})

		if(list){
			this.pricing_list_data  = list.data
			this.pricing_list_start = start
			this.pricing_list_total = list.total
		}
		else {
			this.pricing_list_data  = null
			this.pricing_list_start = null
			this.pricing_list_total = null
		}
		
		this.focusedItem = null
	},
	
	onItemFocus (item){
		if(!this.focusedItem || (this.focusedItem.id != item.id)){
			this.focusedItem = item
		}
	},
  },
  

  created (){
  },
  
  
  computed: {
    pricing_list_fields (){
		return {
			'name': 'Наименование товара',
			'prices': {column: 'Цены', align: 'right', print_eval: function(fields){
				let str = ''
				if(fields.prices){
					Object.keys(fields.prices).map(function(price_id){
						if(fields.prices[price_id]['val']){if(str != '')str+=' / '; str += fields.prices[price_id]['val'];}
					})
				}
				return str
			}},
			'seller_own_prod_id': {column: 'Код товара в системе продавца', align: 'right'},
		}
	},
	
	focused_item_valid (){
		return (this.focusedItem && this.focusedItem.data && this.focusedItem.data.id)
	},
  },
  
  
  watch: {
      // '$route': 'showSellerGroups'
  },
}
</script>