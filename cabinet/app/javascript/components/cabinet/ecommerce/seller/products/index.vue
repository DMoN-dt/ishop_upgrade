<template lang='pug'>
  div.page-block.padding-more.page-products
    h1 {{ $t("seller.products.title_list_index") }}

    .c-panel(v-if="!modeEdit")
      button.btn.btn-thin3d(v-on:click="") {{ $t("seller.products.btn_create") }}
      | &nbsp;
      button.btn.btn-thin3d(:disabled="!focused_product_valid") {{ $t("seller.products.btn_show_info") }}
      button.btn.btn-thin3d(:disabled="!focused_product_valid" @click="modeEdit = true") {{ $t("buttons.Change") }}
    .c-panel(v-else)
      button.btn.btn-thin3d(@click="modeEdit = false") {{ $t("buttons.edit_quit") }}
    
    .seller-product-edit(v-if="modeEdit")
      product-edit(:data="focused_product_data")
    .seller-products(v-else)
      .products-area.border-around
        products-list(
          :data="products_data"
          :data_from="products_data_start"
          :totalCount="products_total_count"
          @fetchMoreData="onFetchMoreData"
          :variantsPerPage="[25,50,100]"
          :currentPerPage="products_per_page"
          @item-focus="onProductFocus")
      
      .groups-area.border-around
        products-groups-tree(:data="groups_tree" :initialFocused="initialFocused" @item-click="groupsTreeItemClick" @item-toggle="groupsTreeItemToggle")
</template>

<script>
import Vue from 'vue'
import ProductEdit from 'components/cabinet/ecommerce/general/seller_product_edit'
import ProductsList from 'components/cabinet/ecommerce/general/seller_products_list'
import ProductsGroupsTree from 'components/cabinet/ecommerce/general/seller_products_groups_tree'

// Для выделенных товаров: Удалить, отключить, переместить в другую группу

export default {
  data (){return {
	  products_data: null,
	  products_data_start: null,
	  products_total_count: null,
	  products_per_page: null,
	  
	  searchGroupText: '',
	  searchProductText: '',
	  
	  initialFocused: null,
      focusedGroup: null,
      focusedProduct: null,
	  
	  modeEdit: false,
  }},
  
  
  components: {
	'product-edit': ProductEdit,
	'products-list': ProductsList,
	'products-groups-tree': ProductsGroupsTree,
  },
  
  
  methods: {
    onFetchMoreData ({start, length, total_unknown}){
		this.loadSellerGroupProducts(start, length, total_unknown)
		this.focusedProduct = null
	},
	
	
	onProductFocus (item){
		if(!this.focusedProduct || (this.focusedProduct.id != item.id)){
			this.focusedProduct = item
		}
	},

	
	async loadSellerGroupProducts (start = 0, maxcnt = 25, get_total = false){
	  let products = await this.$store.dispatch('DataArray_getDataSlice', {
		node: 'products', subnode_id: null,
		params: {seller_id: this.$store.state.cabinet.seller.SellerId, include_subgroups: true},
		start, maxcnt, get_total, order: ['name asc'],
		api_func_load: 'seller.products.fetchList',
	  })

	  if(products){
		this.products_data = products.data
		this.products_data_start = start
		this.products_total_count = products.total
		this.products_per_page = maxcnt
	  }
	  else {
		this.products_data = null
		this.products_data_start = null
		this.products_total_count = null
	  }
    },
	
	
	async groupsTreeItemToggle (node, item, skip_child_num = false) {
	  
    },
	
	
	async groupsTreeItemClick (node, item){
		await this.$store.dispatch('DataArray_setDefaultSubNodeId', {node: 'products', id: item.value.id})
		this.focusedGroup = item
		this.loadSellerGroupProducts()
	},
  },
  
  
  created (){
	  this.initialFocused = this.currentProductsGroupId;
  },
  
  
  computed: {
	groups_tree (){
		if(!this.$store.state.cabinet.seller.products_groups.data)this.$store.dispatch('loadSellerProductsSubGroups');
		return this.$store.state.cabinet.seller.products_groups.data
	},
	
	currentProductsGroupId (){
		return (this.$store.state.data_array.nodes.products ? this.$store.state.data_array.nodes.products.defaultSubNodeId : null)
	},
	
	focused_product_valid (){
		return (this.focusedProduct && this.focusedProduct.data && this.focusedProduct.data.id)
	},
	
	focused_product_data (){
		return {data: ((this.focused_product_valid) ? this.focusedProduct.data : null), group: this.focusedGroup}
	},

  },
  
  watch: {
	  //'$route': 'showSellerGroups',
  },
  
}
</script>