<template lang="pug">
  .product-info-pricing(v-if="ProductData")
    h2 {{ $t('seller.products.title_pricing_info') }}
    
    .row
      .col-sm-6
        .row
          .col
            label.t-grey <strong>{{ $t("seller.products.current_prices") }}</strong>
            pricing-prices(
              :data="ProductPrices" :dataViewFields="pricing_list_fields"
              :data_from="0"
              :dataTotalCount="ProductPrices ? ProductPrices.length : 0"
              :variantsPerPage="[10]" :currentPerPage="10" :showTotalCount="false")
            p.t-grey.hg-tip * {{ $t("seller.products.about_current_price") }}

        .row
          .col
            label.t-grey {{ $t("seller.products.current_base_price") }}: &nbsp;
            span.as-input.hl-value {{ ProductData.prices_upd_base_price }} ({{ base_price_currency }})

        .row
          .col
            br
            label.col-form-label.t-grey {{ $t("seller.products.pricing_math_list") }}:
            listview(
              :data="maths_data" :data_from="maths_from" @fetchMoreData="maths_onFetchMoreData"
              :dataViewFields="maths_list_fields" :dataTotalCount="maths_data_total"
              :variantsPerPage="[10]" :currentPerPage="10" :showTotalCount="false")
            p.t-grey.hg-tip * {{ $t("seller.products.about_base_price") }}


      .col-sm-6
        .row
          .col
            label.t-grey <strong>{{ $t("seller.products.fixed_prices_list") }}</strong>
            listview(
              :data="fixed_prices_data" :data_from="fixed_prices_from" @fetchMoreData="fixed_prices_onFetchMoreData"
              :dataViewFields="fixed_prices_list_fields" :dataTotalCount="fixed_prices_data_total"
              :variantsPerPage="[10]" :currentPerPage="10" :showTotalCount="false")


        .row
          .col
            br
            label.t-grey <strong>{{ $t("seller.products.instock_prices_list") }}</strong>
            listview(
              :data="in_stock_data" :data_from="in_stock_from" @fetchMoreData="in_stock_onFetchMoreData"
              :dataViewFields="in_stock_list_fields" :dataTotalCount="in_stock_data_total"
              :variantsPerPage="[10]" :currentPerPage="10" :showTotalCount="false")


        .row
          .col
            br
            label.t-grey <strong>{{ $t("seller.products.suppliers_prices_list") }}</strong>
            listview(
              :data="suppliers_data" :data_from="suppliers_from" @fetchMoreData="suppliers_onFetchMoreData"
              :dataViewFields="suppliers_list_fields" :dataTotalCount="suppliers_data_total"
              :variantsPerPage="[10]" :currentPerPage="10" :showTotalCount="false")

        

    .row
      .col
        hr
        p.last_updated {{ $t('seller.products.last_update') }}: {{ProductData.updated_at}}

</template>

<script>
import ListView from 'components/general/list-view/listview'

export default {
  name: 'product-pricing',
  props: {
    data: {type: Object},
    editMode: {type: Boolean, default: false},
  },
  
  data (){return {
	  InitialData: {},
	  ProductData: {},
	  ProductPrices: null,
	  main_mode: null,
	  changes_saved_notification: false,
	  
	  general_fields: [
		'id', 'updated_at', 'seller_id', 'seller_group_id', 'name', 'app_scope', 'prices_upd_math_id', 'prices_upd_changing', 'prices_upd_changed', 'prices_upd_base_price',
		'prices_upd_math_ids', 'lot_prices', 'prices_upd_base_price_cn',
	  ],
	  
	  saveable_fields: [
	  ],
	  
	  maths_data: null,
	  maths_from: 0,
	  maths_data_total: 0,
	  
	  fixed_prices_data: null,
	  fixed_prices_from: 0,
	  fixed_prices_data_total: 0,
	  
	  in_stock_data: null,
	  in_stock_from: 0,
	  in_stock_data_total: 0,
	  
	  suppliers_data: null,
	  suppliers_from: 0,
	  suppliers_data_total: 0,
  }},
  
  
  components: {
	  'listview': ListView,
	  'pricing-prices': ListView,
  },
  
  
  methods: {
	async onDataChange (data = this.data){
		let changed = this.product_changes(this.ProductData.id)
		this.main_mode = this.$store.state.cabinet.CabinetGeneralInfo.mode
		
		if(changed && data.id != this.ProductData.id){
		  // ask to save changes of the previous product
		}
		
		await this.fillProduct(data, changed)
		
		this.maths_onFetchMoreData({start: 0, length: 10, total_unknown: !this.maths_data_total})
		this.fixed_prices_onFetchMoreData({start: 0, length: 10, total_unknown: !this.fixed_prices_data})
		this.suppliers_onFetchMoreData({start: 0, length: 10, total_unknown: !this.suppliers_data_total})
		this.in_stock_onFetchMoreData({start: 0, length: 10, total_unknown: !this.in_stock_data})
	},
	
	
	async fillProduct (productItem, changed = this.product_changes(this.ProductData.id)){
		let prod_data = {}, pdata, prod_prices = []
		
		if(productItem){
			if(productItem.data){
				if((typeof productItem.data.reserved == 'undefined') || (typeof productItem.data.prod_info == 'undefined') || (typeof productItem.data.lot_in_stock == 'undefined')){
					if(productItem.data._full_data)pdata = productItem.data._full_data;
					else {
						// Query for Full Product Information
						pdata = await this.$store.dispatch('DataArray_getItemFullData', {
							node: 'products', id: productItem.data.id, item: productItem.data,
							params: {seller_id: productItem.data.seller_id},
							api_func: 'seller.products.show',
						})
						if(!pdata)pdata = productItem.data;
					}
				} else pdata = productItem.data
				
				this.InitialData = pdata
				
				this.general_fields.forEach(function(key){
				  prod_data[key] = pdata[key]
				})
				
				this.saveable_fields.forEach(function(key){
				  prod_data[key] = pdata[key]
				})
				
				
				let pricing_prices_ids = [], stn

				if(prod_data.lot_prices){
					Object.keys(prod_data.lot_prices).map(function(price_id){
						if(!isNaN(price_id)){
							prod_prices.push({
								id: Number(price_id),
								val: prod_data.lot_prices[price_id].val,
								currency_id: (prod_data.lot_prices[price_id].cn ? prod_data.lot_prices[price_id].cn : prod_data.lot_prices.cn),
							})
							
							pricing_prices_ids.push(price_id)
						}
					}, this)
				}

				if(pricing_prices_ids.length){
					let pricing_prices = await this.$store.dispatch('DataArray_getItemFullData', {
						node: 'pricing_prices', id: pricing_prices_ids,
						params: {seller_id: prod_data.seller_id},
						api_func: 'seller.pricing_prices.getInfo',
					})

					if(this.$store.state.cabinet.ecommerce.Currencies){
						prod_prices.forEach(function(rule){
							stn = this.$store.getters.getCurrency(rule.currency_id)
							rule.currency_name = (stn ? (stn.name_ru + ', ' + stn.iso_code_name) : this.$t('messages.undefined'))
							
							pricing_prices.every(function(rule_data){
								if(rule_data.id == rule.id){
									rule.name = rule_data.price_name
									rule.id_data = rule_data
									return false
								}
								return true
							})
						}, this)
					}
				}
			}
		}
		
		this.ProductData = prod_data
		this.ProductPrices = prod_prices
	},
	
	
	product_changes (product_id){
		return false
	},
	
	
	async in_stock_onFetchMoreData ({start, length, total_unknown}){
	  let list
	  
	  if(this.ProductData && (typeof this.ProductData.seller_id != 'undefined')){
		  list = await this.$store.dispatch('DataArray_getDataSlice', {
			node: 'instock_products', subnode_id: this.ProductData.id,
			params: {seller_id: this.ProductData.seller_id},
			start, length, total_unknown,
			api_func_load: 'seller.products.fetchInStock',
		  })
	  }
	  
	  if(list){
		this.in_stock_data = list.data
		this.in_stock_from = start
		this.in_stock_data_total = list.total
	  }
	  else {
		this.in_stock_data = null
		this.in_stock_from = null
		this.in_stock_data_total = null
	  }
	},
	
	
	async suppliers_onFetchMoreData ({start, length, total_unknown}){
	  let list
	  
	  if(this.ProductData && (typeof this.ProductData.seller_id != 'undefined')){
		  list = await this.$store.dispatch('DataArray_getDataSlice', {
			node: 'suppliers_products', subnode_id: this.ProductData.id,
			params: {seller_id: this.ProductData.seller_id},
			start, length, total_unknown,
			api_func_load: 'seller.products.fetchSuppliers',
		  })
	  }
	  
	  if(list){
		this.suppliers_data = list.data
		this.suppliers_from = start
		this.suppliers_data_total = list.total
	  }
	  else {
		this.suppliers_data = null
		this.suppliers_from = null
		this.suppliers_data_total = null
	  }
	},
	
	
	async maths_onFetchMoreData ({start, length, total_unknown}){
	  let list
	  
	  if(this.ProductData && (typeof this.ProductData.seller_id != 'undefined')){
		  list = await this.$store.dispatch('DataArray_getDataSlice', {
			node: 'products_pricing_math', subnode_id: this.ProductData.id,
			params: {seller_id: this.ProductData.seller_id},
			start, length, total_unknown,
			api_func_load: 'seller.products.fetchPricingMath',
		  })
	  }
	  
	  if(list){
		this.maths_data = list.data
		this.maths_from = start
		this.maths_data_total = list.total
	  }
	  else {
		this.maths_data = null
		this.maths_from = null
		this.maths_data_total = null
	  }
	},

	
	async fixed_prices_onFetchMoreData ({start, length, total_unknown}){
	  let list, stn
	  
	  if(this.ProductData && (typeof this.ProductData.seller_id != 'undefined')){
		  list = await this.$store.dispatch('DataArray_getDataSlice', {
			node: 'products_fixed_prices', subnode_id: this.ProductData.id,
			params: {seller_id: this.ProductData.seller_id},
			start, length, total_unknown,
			api_func_load: 'seller.products.fetchFixedPrices',
		  })
	  }
	  
	  if(list){
		if(list.data){
			list.data.forEach(function(price){
				stn = this.$store.getters.getCurrency(price.cn)
				price.currency_name = (stn ? (stn.name_ru + ', ' + stn.iso_code_name) : this.$t('messages.undefined'))
			}, this)
		}
		
		this.fixed_prices_data = list.data
		this.fixed_prices_from = start
		this.fixed_prices_data_total = list.total
	  }
	  else {
		this.fixed_prices_data = null
		this.fixed_prices_from = null
		this.fixed_prices_data_total = null
	  }
	},

	
	fixed_prices_onItemFocus (node, item){
		
	},
	
	
	suppliers_onItemFocus (node, item){
		
	},
	
	
	in_stock_onItemFocus (node, item){
		
	},
  },
  
  
  async created (){
	  await this.onDataChange()
  },
  
  
  computed: {
	
	base_price_currency (){
		let cn_code = this.ProductData.prices_upd_base_price_cn
		if(cn_code){
			let stn = this.$store.getters.getCurrency(cn_code)
			return (stn ? (stn.name_ru + ', ' + stn.iso_code_name) : null)
		}
		return null
	},
	
	fixed_prices_list_fields (){
		return {
			'name': 'Тип цены',
			'val': {column: 'Стоимость', align: 'right', separate_thousands: true, with_field: 'currency_name', with_separator: ' / '},
		}
	},
	
	in_stock_list_fields (){
		return {
			'wrh_short_name': 'Склад',
			'price_calc': {column: 'Реализация', align: 'right'},
			'price_calc_at': {column: 'Расчёт цены', align: 'right'},
			'price': {column: 'Закуп', align: 'right'},
		}
	},
	
	maths_list_fields (){
		return {
			'rule_name': 'Наименование правила',
			'method': {column: 'Метод', align: 'center', values: {'0': 'МИНИМУМ', '1': 'МАКСИМУМ', '2': 'СРЕДНЕЕ', '3': 'ФОРМУЛА'}},
			'round_prices': {column: 'Округление', align: 'center', values: {'true': 'да', 'false': 'нет'}},
			'updated_at': {column: 'Правило обновлено', align: 'right'},
		}
	},
	
	pricing_list_fields (){
		return {
			'name': 'Тип цены',
			'k_multiplier': {column: 'Формула расчёта', print: '( БЦ * ::k_multiplier ) + ::k_plus'},
			'val': {column: 'Цена *', align: 'right', separate_thousands: true, with_field: 'currency_name', with_separator: ' / '},
		}
	},
	
	suppliers_list_fields (){
		return {
			'supp_name': {column: 'Поставщик / склад', with_field: 'wrh_short_name', with_separator: ' / '},
			'price_calc': {column: 'Реализация', align: 'right'},
			'price_calc_at': {column: 'Расчёт цены', align: 'right'},
			'price': {column: 'Закуп', align: 'right'},
		}
	},
  },
  
  watch: {
	  data (to, from){
		  this.onDataChange(to)
	  }
  },
  
}
</script>