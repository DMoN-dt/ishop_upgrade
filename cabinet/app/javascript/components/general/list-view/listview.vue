<template>
  <div>
    <div :class="classes" role="list" onselectstart="return false">
      <ul :class="containerClasses" role="group">
        <div class="table-header">
          <span v-for="title in item_fields_titles" class="field">
            {{title}}
          </span>
        </div>
        <div v-if="data && data.length" class="table-body">
          <listview-item v-for="(child, index) in data"
                   :key="index"
                   :data="child"
                   :fields="item_fields"
                   :fieldsStyle="item_fields_style"
                   :whole-row="wholeRow"
                   :show-checkbox="showCheckbox"
                   :height="sizeHight"
                   :on-item-focus-click="onItemFocusClick"
                   :on-item-select-click="onItemSelectClick">
          </listview-item>
        </div>
        <i v-else class="listview-empty">Список пуст</i>
      </ul>
    </div>
    
    <div :class="footerClasses">
      <listview-paginate :totalPages="total_pages" :currentPage="current_page" @changePageNum="onChangePageNum" :itemsPerPage="per_page_count" :paginateLink="paginateLink"></listview-paginate>
      <p class=" text-right">Всего записей: {{total_items_count}}</p>
      <div v-if="variantsPerPage && (variantsPerPage.length > 1)" class="per_page_controls">
        <span class=" text-right">Показывать: </span>
        <span v-for="vpg in variantsPerPage" :class="(vpg == per_page_count) ? 'variant current' : 'variant'" @click="changePerPageCount(vpg)">{{vpg}}</span>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import ListViewItem from './listview-item.vue'
import ListPagination from 'components/general/pagination/paginate.vue'

let ITEM_ID = 0
let ITEM_HEIGHT_SMALL = 18
let ITEM_HEIGHT_DEFAULT = 24
let ITEM_HEIGHT_LARGE = 32

export default {
  name: 'ListView',
  props: {
    data: {type: Array},
    data_from: {type: Number},
	dataTotalCount: {type: Number},
	dataViewFields: {type: Object},
	
	variantsPerPage: {type: Array, default: () => {[25,50,100]}},
	currentPerPage: {type: Number, default: 25},
	tableView: {type: Boolean, default: true},
	paginateLink: {type: Boolean, default: false},
	
  },
  components: {
	'listview-item': ListViewItem,
	'listview-paginate': ListPagination,
  },
  
  data (){return {
	  currentPage: 0
  }},
  
  
  methods: {
    onChangePageNum (pageNum, itemsPerPage = this.currentPerPage){
		itemsPerPage = this.itemsPerPageValidate(itemsPerPage);
		
		if((pageNum != this.currentPage) || (itemsPerPage != this.currentPerPage)){
			if(pageNum < 1)pageNum = 1

			let newpage_data_start  = (pageNum - 1) * itemsPerPage

			if((newpage_data_start != 0) && (this.total_items_count > 0) && (newpage_data_start >= this.total_items_count)){// recalc pageNum if it exceeds Total Data Range
				let page_min = Math.floor( (this.total_items_count) / itemsPerPage )
				let page_min_total = page_min * itemsPerPage

				if(page_min_total >= this.total_items_count)pageNum = page_min;
				else pageNum = page_min + 1;
				
				newpage_data_start = (pageNum - 1) * itemsPerPage
			}
			
			if(newpage_data_start < 0)newpage_data_start = 0;
			
			if(this.data){
				let data_from = (this.data_from <= 0 ? 0 : this.data_from)
				if((newpage_data_start >= data_from) && (newpage_data_start < (data_from + this.data.length)) && ((newpage_data_start + itemsPerPage) < (data_from + this.data.length))){
					this.currentPage = pageNum
					return
				}
			}

			this.$emit('fetchMoreData', {
				start: newpage_data_start,
				length: itemsPerPage,
				total_unknown: this.total_items_count_is_unknown
			})
			
			this.currentPage = pageNum
		}
	},
	
	itemsPerPageValidate (itemsPerPage){
	  if(!this.variantsPerPage.includes(itemsPerPage)){
		  return (this.variantsPerPage[0] ? this.variantsPerPage[0] : 10)
	  }
	  return itemsPerPage
	},
	
	changePerPageCount (newVal){
		this.onChangePageNum(this.currentPage, newVal)
	},
	
	initializeData (items){
	if(items && items.length > 0){
          for(let i in items){
            items[i] = this.initializeDataItem(items[i])
          }
        }
      },
	  
      initializeDataItem (item) {
        function Model(item, dataTextField, valueFieldName) {
          this.id = item.id || ITEM_ID++
		  this.data = item
          this.icon = item.icon || ''
          this.selected = item.selected || false
          this.focused = item.focused || false
          this.disabled = item.disabled || false
        }
        let node = new Model(item)
        let self = this
		node.setFocus = function () {
          if(node.disabled)return;
		  self.handleRecursionItems(node => {
			if(node.focused)node.focused = false;
		  })
		  node.focused = true
		  self.$emit('item-focus', self, node)
        }
        return node
      },
	  
	  handleRecursionItems (func){
        if(this.data && this.data.length > 0){
          for(let child of this.data){
            if(!child.disabled){
              func(child)
            }
          }
        }
      },
	  
	  onItemFocusClick (oriNode, oriItem){
        this.handleRecursionItems(node => {
		  node.focused = false
        })
		oriNode.model.focused = true
        this.$emit('item-focus', oriNode, oriItem)
      },
	  
	  onItemSelectClick (oriNode, oriItem) {
        if(this.multiple){
            if(this.allowBatch){
                this.handleBatchSelectItems(oriNode, oriItem)
            }
        } else {
          this.handleSingleSelectItems(oriNode, oriItem)
        }
        this.$emit('item-select', oriNode, oriItem)
      },
	  
	// Erased.....
  },
  
  
  created (){
	  this.initializeData(this.data)
  },
  
  
  watch: {
	  data (to, from){
		  this.initializeData(to)
	  }
  },
  
  
  computed: {
	item_fields_columns (){
		let columns = []
		Object.keys(this.dataViewFields).map(function(key, index) {
			if(typeof this.dataViewFields[key] == 'string')columns.push(key);
			else if(typeof this.dataViewFields[key] == 'object'){
				if(typeof this.dataViewFields[key].column == 'string')columns.push(key);
			}
		}, this)
		return columns
	},
	
	item_fields_style (){
		let columns = []
		Object.keys(this.dataViewFields).map(function(key, index) {
			if(typeof this.dataViewFields[key] == 'object')columns.push({field: key, data: this.dataViewFields[key]});
		}, this)
		return columns
	},
	
	item_fields (){
		return (this.dataViewFields ? this.item_fields_columns : null)
	},
	
	item_fields_titles (){
		//return (this.dataViewFields ? Object.values(this.dataViewFields) : null)
		let titles = []
		this.item_fields_columns.forEach(function(key){
			if(typeof this.dataViewFields[key] == 'string')titles.push(this.dataViewFields[key]);
			else if((typeof this.dataViewFields[key] == 'object') && (typeof this.dataViewFields[key].column == 'string'))titles.push(this.dataViewFields[key].column);
		}, this)
		return titles
	},
	
	total_items_count_is_unknown (){
		return ((typeof this.dataTotalCount == 'undefined') || (this.dataTotalCount == null))
	},
	
	total_items_count (){
		return ((this.dataTotalCount <= 0) ? ((this.data && this.data.length) ? (this.data_from + this.data.length) : 0) : this.dataTotalCount)
	},
	
	total_pages (){
		return Math.ceil( this.total_items_count / this.currentPerPage )
	},
	
	current_page (){
		if(this.data && this.data.length){
			if((typeof this.data_from != 'undefined') && (this.data_from != null)){
				let page = Math.ceil( (this.data_from + 1) / this.currentPerPage )
				if(page != this.currentPage){
					this.currentPage = ((page >= 1) ? page : 1)
					return page
				}
			}
		}
		return ((this.currentPage >= 1) ? this.currentPage : 1)
	},
	
	per_page_count (){
	  return this.itemsPerPageValidate(this.currentPerPage)
	},
	
	classes () {
      return [
        {'listview': true},
        {'listview-default': !this.size},
        {[`listview-default-${this.size}`]: !!this.size},
        {'listview-checkbox-selection': !!this.showCheckbox},
		{'table': this.tableView},
      ]
    },
	
  },
}

</script>