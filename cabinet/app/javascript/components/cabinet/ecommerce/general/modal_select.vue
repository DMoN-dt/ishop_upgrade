<template>
  <div>
    <div class="modal fade show modal-select" id="modalSelect" tabindex="-1" role="dialog" aria-hidden="true" style="display: block;">
      <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ modalTitle }}</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close" @click="clickClose">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <products-groups-tree v-if="selectFor == 'group'" :data="groups_tree" :initialFocused="groups_initialFocused" @item-click="groupsTreeItemClick"></products-groups-tree>

            <brands-list v-if="selectFor == 'brand'"
              :data="brands_data"
              :data_from="brands_data_start"
              :totalCount="brands_total_count"
              @fetchMoreData="onBrandsFetchMoreData"
              :variantsPerPage="[10]"
              :currentPerPage="brands_per_page"
              :listFields="{'name': 'Наименование брэнда'}"
              @item-focus="brandsItemFocus"></brands-list>

            <countries-list v-if="selectFor == 'country'"
              :data="countries_data"
              :data_from="countries_data_start"
              :totalCount="countries_total_count"
              @fetchMoreData="onCountriesFetchMoreData"
              :variantsPerPage="[10]"
              :currentPerPage="countries_per_page"
              :listFields="{'name_full_rus': 'Страна', 'iso_code_3': 'Код'}"
              @item-focus="countriesItemFocus"></countries-list>

            <measure-unit-list v-if="selectFor == 'measure_unit'"
              :data="measure_units_data"
              :data_from="measure_units_data_start"
              :totalCount="measure_units_total_count"
              @fetchMoreData="onMeasureUnitFetchMoreData"
              :variantsPerPage="[10]"
              :currentPerPage="measure_units_per_page"
              :listFields="{'rus_full_name': 'Единица измерения', 'rus_short_name': 'Обозначение', 'rus_okei_code': 'Код по ОКЕИ'}"
              @item-focus="measureunitItemFocus"></measure-unit-list>
              
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="clickClose">{{ $t("buttons.Cancel") }}</button>
            <button type="button" class="btn btn-primary" @click="clickOk" :disabled="disabledOk">{{ $t("buttons.OK") }}</button>
          </div>
        </div>
      </div>
    </div>
    <div class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
import ProductsGroupsTree from 'components/cabinet/ecommerce/general/seller_products_groups_tree'
import BrandsList from 'components/cabinet/ecommerce/general/seller_brands_list'

export default {
  name: 'modal-select',
  props: {
    selectFor: {type: String},
    data: {type: Object, default: null},
    name: {type: String, default: null},
  },
  
  data (){return {
	  disabledOk: true,
	  seller_id: null,
	  
	  focusedGroup: null,
	  
	  focusedBrand: null,
	  brands_data: null,
	  brands_data_start: null,
	  brands_total_count: null,
	  brands_per_page: null,
	  
	  focusedCountry: null,
	  countries_data: null,
	  countries_data_start: null,
	  countries_total_count: null,
	  countries_per_page: null,
	  
	  focusedMeasureUnit: null,
	  measure_units_data: null,
	  measure_units_data_start: null,
	  measure_units_total_count: null,
	  measure_units_per_page: null,

  }},
  
  components: {
	'products-groups-tree': ProductsGroupsTree,
	'brands-list': BrandsList,
	'countries-list': BrandsList,
	'measure-unit-list': BrandsList,
  },
  
  
  methods: {
	clickOk (event){
	  let data = null
	  
	  switch(this.selectFor){
		case 'group':
		  if(this.focusedGroup){
			  data = {id: this.focusedGroup.value.id, text: this.focusedGroup.text, item: this.focusedGroup}
		  }
		  break;
		case 'country':
		  if(this.focusedCountry){
			  data = {id: this.focusedCountry.id, code: this.focusedCountry.data.country_code, text: this.focusedCountry.data.name_full_rus, item: this.focusedCountry}
		  }
		  break;
		case 'brand':
		  if(this.focusedBrand){
			  data = {id: this.focusedBrand.id, text: this.focusedBrand.data.name, item: this.focusedBrand}
		  }
		  break;
		case 'measure_unit':
		  if(this.focusedMeasureUnit){
			  data = {id: this.focusedMeasureUnit.id, text: this.focusedMeasureUnit.data.rus_full_name, item: this.focusedMeasureUnit.data}
		  }
		  break;
	  }
	  
	  if(data){data['type'] = this.selectFor; data['from_name'] = this.name;}
	  this.$emit('modal-return', true, data)
	},
	
	clickClose (event){
	  this.$emit('modal-return', false, null)
	},
	
	
	// Groups Tree Methods
	// -------------------
	groupsTreeItemClick (node, item){
	  this.focusedGroup = item
	  this.disabledOk = false
	},
	
	
	// Brands List Methods
	// -------------------
	onBrandsFetchMoreData ({start, length, total_unknown}){
		this.loadSellerBrands(start, length, total_unknown)
		this.focusedBrand = null
	},
	
	
	brandsItemFocus (item){
		if(!this.focusedBrand || (this.focusedBrand.id != item.id)){
			this.focusedBrand = item
			this.disabledOk = false
		}
	},

	
	async loadSellerBrands (start = 0, maxcnt = 25, get_total = false){
	  let brands = await this.$store.dispatch('DataArray_getDataSlice', {
		node: 'brands',
		start, maxcnt, get_total, order: ['name asc'],
		params: {seller_id: this.seller_id},
		api_func_load: 'seller.brands.fetchList',
	  })
	  
	  if(brands){
		this.brands_data = brands.data
		this.brands_data_start = start
		this.brands_total_count = brands.total
		this.brands_per_page = maxcnt
	  }
	  else {
		this.brands_data = null
		this.brands_data_start = null
		this.brands_total_count = null
	  }
    },
	
	
	// Countries List Methods
	// ----------------------
	onCountriesFetchMoreData ({start, length, total_unknown}){
		this.loadCountries(start, length, total_unknown)
		this.focusedCountry = null
	},
	
	
	countriesItemFocus (item){
		if(!this.focusedCountry || (this.focusedCountry.id != item.id)){
			this.focusedCountry = item
			this.disabledOk = false
		}
	},

	
	async loadCountries (start = 0, maxcnt = 25, get_total = false){
	  let countries = await this.$store.dispatch('DataArray_getDataSlice', {
		node: 'countries',
		start, maxcnt, get_total, order: ['name_full_rus asc'],
		api_func_load: 'general.countries.fetchList',
	  })
	  
	  if(countries){
		this.countries_data = countries.data
		this.countries_data_start = start
		this.countries_total_count = countries.total
		this.countries_per_page = maxcnt
	  }
	  else {
		this.countries_data = null
		this.countries_data_start = null
		this.countries_total_count = null
	  }
    },

	
	// Measurement Units List Methods
	// ------------------------------
	onMeasureUnitFetchMoreData ({start, length, total_unknown}){
		this.loadMeasureUnits(start, length, total_unknown)
		this.focusedMeasureUnit = null
	},
	
	
	measureunitItemFocus (item){
		if(!this.focusedMeasureUnit || (this.focusedMeasureUnit.id != item.id)){
			this.focusedMeasureUnit = item
			this.disabledOk = false
		}
	},

	
	async loadMeasureUnits (start = 0, maxcnt = 25, get_total = false){
	  let measure_units = await this.$store.dispatch('DataArray_getDataSlice', {
		node: 'measure_unit',
		start, maxcnt, get_total, order: ['frequently_used_quantity desc', 'top_sort_order asc', 'm_type_id asc', 'rus_full_name asc'],
		api_func_load: 'general.measure_units.fetchList',
	  })
	  
	  if(measure_units){
		this['measure_units_data'] = measure_units.data
		this['measure_units_data_start'] = start
		this['measure_units_total_count'] = measure_units.total
		this['measure_units_per_page'] = maxcnt
	  }
	  else {
		this['measure_units_data'] = null
		this['measure_units_data_start'] = null
		this['measure_units_total_count'] = null
	  }
    },
	
  },
  
  created (){
	  this.seller_id = this.$store.state.cabinet.seller.SellerId
  },
  
  computed: {
	  modalTitle (){
		  switch(this.selectFor){
			  case 'group': return this.$t("messages.choose_group");
			  case 'brand': return this.$t("messages.choose_brand");
			  case 'country': return this.$t("messages.choose_country");
			  case 'measure_unit': return this.$t("messages.choose_measure_unit");
			  default: return this.$t("messages.choose_smth");
		  }
	  },
	  
	  groups_tree (){
		return ((this.data && this.data.tree) ? this.data.tree : null)
	  },
	  
	  groups_initialFocused (){
		return ((this.data && this.data.initialFocused) ? this.data.initialFocused : null)
	  },
  }
}
</script>