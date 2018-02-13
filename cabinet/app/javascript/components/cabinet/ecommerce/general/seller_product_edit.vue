<template lang="pug">
  .product-edit(v-if="ProductData")
    h2 Основная информация
    modal-select(v-if="modalSelectMode" :selectFor="modalSelectMode" :data="modalData" :name="modalName" @modal-return="onModalSelectReturn")
    .row
      .col-sm-6
        label.t-grey: strong ID:&nbsp;
        span.val {{ProductData.id}}
        .form-group.row
          .col-sm-5
            input#use_prod_artikul(type="checkbox" v-model="prod_artikul_on" v-bind:value="true")
            label.t-grey.col-form-label(for="use_prod_artikul") {{ $t("seller.products.prod_artikul") }}
          .col-sm-7: input#prod_artikul.form-control(v-model="ProductData.prod_artikul" :disabled="!prod_artikul_on")
        .form-group.row
          .col-sm-5
            input#use_seller_own_prod_id(type="checkbox" v-model="seller_own_prod_id_on" v-bind:value="true")
            label.t-grey.col-form-label(for="use_seller_own_prod_id") {{ $t("seller.products.seller_own_prod_id") }}
          .col-sm-7: input#seller_own_prod_id.form-control(v-model.number="ProductData.seller_own_prod_id" :disabled="!seller_own_prod_id_on" type="number")
        .form-group.row
          .col-sm-3: label.col-form-label.t-grey(for="name") {{ $t("seller.products.name") }}
          .col-sm-9: .input-group: input#name.form-control(v-model="ProductData.name" maxlength="150")
        .form-group.row
          .col-sm-3: label.col-form-label.t-grey(for="prod_code") {{ $t("seller.products.product_code") }}
          .col-sm-9: .input-group: input#prod_code.form-control(v-model="ProductData.prod_code")
        .form-group.row
          .col-sm-3: label.col-form-label.t-grey(for="seller_group_id") {{ $t("seller.products.seller_group_id") }}
          .col-sm-9
            .input-group
              input#seller_group_id.form-control.ro-normal(v-model="product_group_name" readonly)
              .input-group-append: button.btn.btn-outline-secondary(type="button" @click="clickSelectGroup") {{'...'}}
        .form-group.row
          .col-sm-6
            label(for="bactive" :class="bactiveClasses")
              input.form-check-input#bactive(type="checkbox" v-model="ProductData.bactive" v-bind:value="true")
              |{{ $t("seller.products.active") }}
          .col-sm-6.text-right
            label(for="to_delete" :class="deleteClasses")
              input.form-check-input#to_delete(type="checkbox" v-model="ProductData.to_delete" v-bind:value="true")
              |{{ $t("seller.products.to_delete") }}
        .form-group.row
          .col-sm-6
            label(for="is_popular" :class="popularClasses")
              input.form-check-input#is_popular(type="checkbox" v-model="ProductData.is_popular" v-bind:value="true")
              |{{ $t("seller.products.is_popular") }}
        .form-group.row
          .col
            label.col-form-label.t-grey(for="desc_thumb") {{ $t("seller.products.desc_thumb") }}
            .input-group: textarea#desc_thumb.form-control(v-model="ProductData.desc_thumb")
        .form-group.row
          .col
            label.col-form-label.t-grey(for="desc_full") {{ $t("seller.products.desc_full") }}
            .input-group: textarea(rows=5)#desc_full.form-control(v-model="ProductData.desc_full")
        .form-group.row
          .col
            label.col-form-label.t-grey(for="tax_system") {{ $t("seller.products.tax_system") }}:&nbsp;
            span.hl-value {{ gov_tax_system_inherited_value }} <i class="t-grey">({{ $t("seller.products.inherited") }})</i>
        .form-group.row
          .col
            label.col-form-label.t-grey(for="tax_rate") {{ $t("seller.products.tax_rate") }}:&nbsp;
            span.hl-value {{ gov_tax_inherited_value }} <i class="t-grey">({{ $t("seller.products.inherited") }})</i>
      
      .col-sm-6
        .image-area
          .image-preview
          .images-list
        .brand-info.col
          .row
            label.col-form-label.t-grey(for="brand_name") {{ $t("seller.products.brand") }}
            .input-group
              input#brand_name.form-control.ro-normal(v-model="brand_name" readonly)
              .input-group-append: button.btn.btn-outline-secondary(type="button" @click="clickSelectBrand") {{'...'}}
          .row
            .col
              label.col-form-label.t-grey(for="brand_country") {{ $t("seller.products.brand_country") }}:&nbsp;
              span {{ brand_country }}
          .row
            .col
              label.col-form-label.t-grey(for="manufacture_country") {{ $t("seller.products.brand_manufacture_country") }}:&nbsp;
              span {{ brand_manufacture_country }}
        .form-group.row
          .col-sm-5
            input#use_manuf_country(type="checkbox" v-model="prod_manuf_country_on" v-bind:value="true")
            label.t-grey.col-form-label(for="use_manuf_country") {{ $t("seller.products.manufacture_country") }}
          .col-sm-7
            .input-group
              input#manuf_country.form-control.ro-normal(:value="prod_manuf_country" :disabled="!prod_manuf_country_on" readonly)
              .input-group-append: button.btn.btn-outline-secondary(type="button" :disabled="!prod_manuf_country_on" @click="clickSelectCountry") {{'...'}}
        hr
        b.mb-2 {{ $t("seller.products.sell_props_title") }}
        .form-group.row
          .col-sm-6
            label(for="show_at_estore" :class="show_at_estore_Classes")
              input.form-check-input#show_at_estore(type="checkbox" v-model="show_at_estore" v-bind:value="true" :disabled="!ProductData.bactive")
              |{{ $t("seller.products.show_at_estore") }}
          .col-sm-6
            .input-group
              label(for="sell_at_estore" :class="sell_at_estore_Classes")
                input#sell_at_estore(type="radio" name="sell_at_estore" v-model="sell_at_estore" v-bind:value="true" :disabled="!showAtEstore")
                |{{ $t("seller.products.sell_at_estore") }}
        .form-group.row
          .col-sm-6
            label(for="show_price_at_estore" :class="show_price_at_estore_Classes")
              input.form-check-input#show_price_at_estore(type="checkbox" v-model="show_price_at_estore" v-bind:value="true" :disabled="!showAtEstore")
              |{{ $t("seller.products.show_price_at_estore") }}
          .col-sm-6
            .input-group
              label(for="not_for_sale_at_estore" :class="not_sell_at_estore_Classes")
                input#not_for_sale_at_estore(type="radio" name="sell_at_estore" v-model="sell_at_estore" v-bind:value="false" :disabled="!showAtEstore")
                |{{ $t("seller.products.not_for_sale_at_estore") }}
        .form-group.row
          .col-sm-6
            label(for="not_on_sale" :class="not_on_sale_Classes")
              input.form-check-input#not_on_sale(type="checkbox" v-model="not_on_sale" v-bind:value="true")
              |{{ $t("seller.products.not_on_sale") }}
          .col-sm-6(v-if="main_mode == 'full'")
            label(for="allow_offline_sales" :class="sell_at_offline_Classes")
              input.form-check-input#allow_offline_sales(type="checkbox" v-model="sell_at_offline" v-bind:value="true" :disabled="!ProductData.bactive")
              |{{ $t("seller.products.allow_offline_sales") }}

        .row
          .col
            tabs(:klass="'tabs-default'")
              tab(title="Основное предложение" :selected="true")
                .form-group.row
                  .col-sm-5
                    label.t-grey.col-form-label(for="gen_measure_unit") {{ $t("seller.products.measure_unit") }}
                  .col-sm-7
                    .input-group
                      input#gen_measure_unit.form-control.ro-normal(:value="lot_measure_unit" readonly)
                      .input-group-append: button.btn.btn-outline-secondary(type="button" @click="clickSelectMeasureUnit('lot_measure')") {{'...'}}
                .row
                  .col
                    .form-group.input-group
                      label(for="lot_price_entire")
                        input#lot_price_entire(type="radio" name="lot_price_type" v-model="ProductData.lot_cost_type" v-bind:value="0")
                        |{{ $t("seller.products.lot_price_entire") }}
                    
                    
                    .form-group.input-group
                      label(for="lot_price_unit")
                        input#lot_price_unit(type="radio" name="lot_price_type" v-model="ProductData.lot_cost_type" v-bind:value="1")
                        |{{ $t("seller.products.lot_price_unit") }}

                div(v-if="ProductData.lot_cost_type == 1")
                  .form-group.row
                    .col-sm-6
                      label.t-grey.col-form-label(for="lot_units_measure_type") {{ $t("seller.products.lot_units_measure_type") }}
                    .col-sm-6
                      .input-group
                        input#lot_units_measure_type.form-control.ro-normal(:value="lot_unit_measure_type" readonly)
                        .input-group-append: button.btn.btn-outline-secondary(type="button" @click="clickSelectMeasureUnit('lot_unit_measure')") {{'...'}}
                  
                  .form-group.row
                    .col-sm-6
                      label.t-grey.col-form-label(for="lot_units_count") {{ $t("seller.products.lot_units_count") }}
                    .col-sm-4
                      .input-group
                        input#lot_units_count.form-control(:v-model.number="ProductData.lot_unit_count" :type="(unit_measure_type_Data && unit_measure_type_Data.integer_only) ? 'number' : 'text'")
</template>

<script>
import Vue from 'vue'
import {ProductsGroupsTreeItemRootData} from 'store/modules/cabinet/ecommerce/seller/products_groups_functions'
import ModalSelect from 'components/cabinet/ecommerce/general/modal_select'
import Tabs from 'components/general/tabs/tabs'
import TabsItem from 'components/general/tabs/tabs-item'

const PRODUCT_NOT_ON_SALE = 1
const PRODUCT_SHOW_AT_ESTORE = 2
const PRODUCT_SHOW_PRICE_AT_ESTORE = 4
const PRODUCT_SELL_AT_ESTORE = 8
const PRODUCT_SELL_AT_OFFLINE = 16

export default {
  name: 'product-edit',
  props: {
    data: {type: Object},
  },
  
  data (){return {
	  prod_artikul_on: false,
	  seller_own_prod_id_on: false,
	  prod_manuf_country_on: false,
	  prod_manuf_country_id: 0,
	  measure_type_inherit: false,
	  lot_measure_type_id: null,
	  lot_measure_type_name: null,
	  lot_measure_type_Data: null,
	  unit_measure_type_id: null,
	  unit_measure_type_name: null,
	  unit_measure_type_Data: null,
	  
	  not_on_sale: false,
	  show_at_estore: false,
	  show_price_at_estore: false,
	  sell_at_estore: false,
	  sell_at_offline: false,
	  
	  ProductData: {},
	  ProductChanges: null,
	  ProductGroup: null,
	  ProductBrand: null,
	  ProductCountry: null,
	  main_mode: null,
	  
	  modalSelectMode: null,
	  modalData: null,
	  modalName: null,
  }},
  
  
  components: {
	  'modal-select': ModalSelect,
	  'tabs': Tabs,
	  'tab': TabsItem,
  },
  
  
  methods: {
	async onDataChange (data = this.data){
		let changed = this.product_changes(this.ProductData.id)
		this.main_mode = this.$store.state.cabinet.CabinetGeneralInfo.mode
		
		if(changed && data.id != this.ProductData.id){
		  // ask to save changes of the previous product
		}
		
		await this.fillProduct(data, changed)
	},
	  
	  
	async fillProduct (productItem, changed = this.product_changes(this.ProductData.id)){
		let prod_data = {}, pdata
		
		// Erased....
		
		this.ProductData = prod_data
	},
	
	
	clickSelectBrand (){
		this.modalData = {}
		this.modalSelectMode = 'brand'
	},
	
	
	clickSelectCountry (){
		this.modalData = {}
		this.modalSelectMode = 'country'
	},
	
	
	clickSelectGroup (){
		this.modalData = {tree: this.groups_tree, initialFocused: this.ProductData.seller_group_id}
		this.modalSelectMode = 'group'
	},
	
	
	clickSelectMeasureUnit (modalName = null){
		this.modalData = {}
		this.modalName = modalName
		this.modalSelectMode = 'measure_unit'
	},

	
	async onModalSelectReturn (is_selected, data){
		this.modalSelectMode = null
		this.modalData = null

		if(is_selected && data){
			switch(data.type){
				case 'brand':
				  this.ProductBrand = await this.$store.dispatch('DataArray_getItemFullData', {
					node: 'brands', id: data.id,
					params: {seller_id: this.ProductData.seller_id},
					api_func: 'seller.brands.show',
				  })
				  if(this.ProductBrand)this.ProductData.seller_brand_id = this.ProductBrand.id;
				  break;
				case 'country':
				  this.ProductCountry = {code: data.code, name: data.text}
				  break;
				case 'group':
				  this.ProductData.seller_group_id = data.id
				  this.ProductGroup = data.item
				  break;
				case 'measure_unit':
				  console.log('measure_unit data ', data)
				  console.log('measure_unit from ', data.from_name)
				  
				  if(data.from_name == 'lot_measure'){
					this.ProductData.lot_measure_type = data.id
					this.lot_measure_type_Data = data.item
				  }
				  else if(data.from_name == 'lot_unit_measure'){
					this.ProductData.lot_unit_type = data.id
					this.unit_measure_type_Data = data.item
				  }
				  break;
			}
		}
	},


	  
	value_is_not_inherit (value, negative_allowed = true){
		return (
		((typeof value == 'integer') && (value != null) && (value != 0) && (negative_allowed || (value > 0))) ||
		((typeof value == 'boolean') && (value != null)) ||
		((typeof value != 'undefined') && value)
		)
	},
	  
	  
	gov_tax_name (res){
		res = this.$store.state.cabinet.seller.GovTaxes.find(function(item){return (item.id == res)})
		return (res ? (res.name_full || res.name) : this.$t('messages.undefined'))
	},
	
	gov_tax_system_name (res){
		res = this.$store.state.cabinet.seller.GovTaxSystems.find(function(item){return (item.id == res)})
		return (res ? (res.name_full || res.name) : this.$t('messages.undefined'))
	},
	
	measure_type_name_existing (id){
		let res = this.$store.getters.DataArray_getItemById({node: 'measure_units', id})
		return ((res && res.length) ? (res[0].rus_full_name) : null)
	},
	
	async retrieve_lot_measure_type_name (id, var_prefix = ''){
		let var_name = var_prefix + '_id'
		
		if(this[var_name] != id){
			this[var_name] = id
			
			let res = await this.$store.dispatch('getProductQuantityMeasureUnitById', id)
			
			if(this[var_name] != id){
				this[var_prefix + '_Data'] = res
				
				res = (res ? (res.rus_full_name) : this.$t('messages.undefined'))
				var_name = var_prefix + '_name'
				if(this[var_name] != res)this[var_name] = res
			}
		}
	},
	
	lot_measure_type_name_get (id, var_prefix = ''){
		let res = this.measure_type_name_existing(id)
		if(res)return res;
		
		res = var_prefix + '_measure_type_name'
		this[res] = this.$t('messages.undefined')
		this.retrieve_lot_measure_type_name(id, var_prefix + '_measure_type')
		return this[res]
	},
	  
	  
	product_changes (product_id){
		return false
	},
  },
  
  
  async created (){
	  await this.onDataChange()
  },
  
  
  computed: {
	deleteClasses (){
	  return [
		{'to_delete': this.ProductData.to_delete},
		{'t-grey': !this.ProductData.to_delete},
	  ]
	},
	  
	bactiveClasses (){
	  return [
		{'active': this.ProductData.bactive},
		{'t-grey': !this.ProductData.bactive},
	  ]
	},
	  
	popularClasses (){
	  return [
		{'is_popular': this.ProductData.is_popular},
		{'t-grey': !this.ProductData.is_popular},
	  ]
	},
	
	showAtEstore () {
		return (this.ProductData.bactive && this.show_at_estore)
	},
	
	show_at_estore_Classes (){
	  return [
		{'active': this.showAtEstore},
		{'t-grey': !this.showAtEstore},
	  ]
	},

	sell_at_estore_Classes (){
	  return [
		{'active': this.showAtEstore && this.sell_at_estore},
		{'t-grey': !this.showAtEstore || !this.sell_at_estore},
	  ]
	},
	
	not_sell_at_estore_Classes (){
	  return [
		{'not_on_sale': this.showAtEstore && !this.sell_at_estore},
		{'t-grey': !this.showAtEstore || this.sell_at_estore},
	  ]
	},

	show_price_at_estore_Classes (){
	  return [
		{'active': this.showAtEstore && this.show_price_at_estore},
		{'t-grey': !this.showAtEstore || !this.show_price_at_estore},
	  ]
	},

	not_on_sale_Classes (){
	  return [
		{'not_on_sale': this.not_on_sale},
		{'t-grey': !this.not_on_sale},
	  ]
	},

	sell_at_offline_Classes (){
	  return [
		{'active': this.ProductData.bactive && this.sell_at_offline},
		{'t-grey': !this.ProductData.bactive || !this.sell_at_offline},
	  ]
	},

	
	gov_tax_inherited_value (){
		let res
		
		if(this.$store.state.cabinet.seller.GovTaxes){
			res = ProductsGroupsTreeItemRootData(
				this.ProductData.seller_group_id,
				(this.ProductExtra && this.ProductExtra.group) ? this.ProductExtra.group.value.initial_parent : null,
				'gov_tax_id', 'GovTax',
				this.$store.state.cabinet.seller.products_groups.changes_exists ? this.$store.state.cabinet.seller.products_groups.changes : null,
				this.$store.state.cabinet.seller.Defaults
			)
		}

		return this.gov_tax_name(res)
	},
	
	gov_tax_system_inherited_value (){
		let res
		
		if(this.$store.state.cabinet.seller.GovTaxSystems){
			res = ProductsGroupsTreeItemRootData(
				this.ProductData.seller_group_id,
				(this.ProductExtra && this.ProductExtra.group) ? this.ProductExtra.group.value.initial_parent : null,
				'gov_tax_system_id', 'GovTaxSystem',
				this.$store.state.cabinet.seller.products_groups.changes_exists ? this.$store.state.cabinet.seller.products_groups.changes : null,
				this.$store.state.cabinet.seller.Defaults
			)
		}

		return this.gov_tax_system_name(res)
	},
	
	lot_measure_type_inherited_value (){
		let res = ProductsGroupsTreeItemRootData(
			this.ProductData.seller_group_id,
			(this.ProductExtra && this.ProductExtra.group) ? this.ProductExtra.group.value.initial_parent : null,
			'def_measure_type', 'ProdMeasureUnit',
			this.$store.state.cabinet.seller.products_groups.changes_exists ? this.$store.state.cabinet.seller.products_groups.changes : null,
			this.$store.state.cabinet.seller.Defaults
		)
		return res
	},
	
	product_group_name (){
		if(this.ProductGroup){
			if(this.ProductGroup.id == this.ProductData.seller_group_id){
				return ((this.ProductGroup.id > 0) ? this.ProductGroup.text : this.$t('seller.prodgroups.root_group_name'))
			}
		}
		return null
	},
	
	brand_name (){
		return (this.ProductBrand ? this.ProductBrand.brand_name : null)
	},
	
	brand_country (){
		if(this.ProductBrand && this.ProductBrand._countries && this.ProductBrand.vendor_brand_country){
			let find_id = this.ProductBrand.vendor_brand_country
			let country = this.ProductBrand._countries.find(o => o.country_code == find_id)
			if(country)return country.name_full_rus;
		}
		return this.$t('messages.undefined')
	},
	
	brand_manufacture_country (){
		if(this.ProductBrand && this.ProductBrand._countries && this.ProductBrand.vendor_products_country){
			let find_id = this.ProductBrand.vendor_products_country
			let country = this.ProductBrand._countries.find(o => o.country_code == find_id)
			if(country)return country.name_full_rus;
		}
		return this.$t('messages.undefined')
	},
	
	prod_manuf_country (){
		if(this.ProductCountry){
			return this.ProductCountry.name
		}
		
		if(this.ProductData.prod_info && this.ProductData.prod_info.pctry){
			let ccode = Number(this.ProductData.prod_info.pctry) + ''
			if(this.ProductBrand && this.ProductBrand._countries && this.ProductBrand._countries[ccode]){
				return this.ProductBrand._countries[ccode].name_full_rus
			}
		}
		
		return (this.prod_manuf_country_on ? this.$t('messages.undefined') : null)
	},
	
	groups_tree (){
		if(!this.$store.state.cabinet.seller.products_groups.data)this.$store.dispatch('loadSellerProductsSubGroups');
		return this.$store.state.cabinet.seller.products_groups.data
	},
	
	lot_measure_unit (){
		if(this.ProductData.lot_measure_type){
			if(this.lot_measure_type_Data && (this.lot_measure_type_Data.id == this.ProductData.lot_measure_type)){
				return this.lot_measure_type_Data.rus_full_name
			}
			return this.lot_measure_type_name_get(this.ProductData.lot_measure_type, 'lot')
			
		} else {
			return (this.lot_measure_type_name_get(this.lot_measure_type_inherited_value, 'lot') + ' (' + this.$t("seller.products.inherited") + ')' )
		}
	},
	
	lot_unit_measure_type (){
		if(this.ProductData.lot_unit_type){
			if(this.unit_measure_type_Data && (this.unit_measure_type_Data.id == this.ProductData.lot_unit_type)){
				return this.unit_measure_type_Data.rus_full_name
			}
			return this.lot_measure_type_name_get(this.ProductData.lot_unit_type, 'unit')
			
		} else {
			return this.lot_measure_type_name_get(this.ProductData.lot_measure_type, 'unit')
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