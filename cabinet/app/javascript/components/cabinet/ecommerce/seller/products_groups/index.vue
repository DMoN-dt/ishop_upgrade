<template lang='pug'>
  .page-block.padding-more.page-prod-groups
    h1 {{ $t("seller.prodgroups.title_list_index") }}
    
    .c-panel
      button.btn.btn-thin3d(v-on:click="switchToAddNewMode") {{ $t("seller.prodgroups.btn_add_new") }}
      router-link.btn.btn-thin3d(:to="group_products_path" :disabled="!focused_item_valid") {{ $t("seller.prodgroups.btn_goto_products") }}
    
    .seller-prod-groups(v-if="data_read_success")
      .groups
        products-groups-tree(:data="groups_tree" show-checkbox multiple allow-batch whole-row draggable @item-click="treeItemClick" @item-dropped="treeItemDropped" @item-select="treeItemSelectClick")
        .info
          .add-new(v-if="addnew_mode")
            p: b {{ $t("seller.prodgroups.group_creation") }}
            .form-group
              label.t-grey(for="group_name") {{ $t("seller.prodgroups.group_name") }}
              .input-group: input#group_name.form-control(v-model="newData.group_name")
            .form-group
              label.t-grey(for="group_descr") {{ $t("seller.prodgroups.group_descr") }}
              .input-group: input#group_descr.form-control(v-model="newData.group_descr")
            .form-group
              label.t-grey(for="group_descr") {{ $t("seller.prodgroups.parent_group") }}
              .input-group: input#group_descr.form-control(v-model="new_group_parent" readonly)
              .small * {{ $t("seller.prodgroups.select_parent_group") }}
            .form-group
              input#group_active(type="checkbox" v-model="newData.bactive" v-bind:value="true")
              label(for="group_active") &nbsp;{{ $t("seller.prodgroups.group_active") }}
            .d-block.text-right.buttons
              button.btn.btn-success(v-on:click="createNewGroup") {{ $t("buttons.Create") }}
              button.btn.btn-secondary(v-on:click="infopanel_mode = 'summary'") {{ $t("buttons.Cancel") }}
          
          .summary(v-else-if="focused_item_valid && summary_mode")
            div(v-if="!focusedItem.value.root")
              .form-group
                label.t-grey(for="group_name") {{ $t("seller.prodgroups.group_name") }}
                .input-group: input#group_name.form-control(v-model="fiData.group_name" readonly)
              .form-group
                label.t-grey(for="group_descr") {{ $t("seller.prodgroups.group_descr") }}
                .input-group
                  input#group_descr.form-control(v-if="fiData.group_descr" v-model="fiData.group_descr" readonly)
                  input#group_descr.form-control.font-italic.t-grey(v-else :placeholder="$t('messages.absent')" readonly)
              .form-group
                .input-group.sort_order
                  p {{ $t("seller.prodgroups.sort_order") }} {{ fiData.sort_order }}
              
              p(v-if="group_parent_is_active")
                span.hl-value(v-if="fiData.bactive") {{ $t("seller.prodgroups.group_active") }}
                b.hl-value(v-else) {{ $t("seller.prodgroups.group_inactive") }}
              p(v-else) <b>{{ $t("seller.prodgroups.parent_group_inactive") }}</b>

              hr
            .d-block
              p: b {{ $t("seller.products.title_group_opts") }}
              p {{ $t("seller.products.measure_unit") }}&nbsp;
                span.hl-value(v-if="fiData.def_measure_type_inherit") {{ def_measure_type_inherited_value }} <i class="t-grey">({{ $t("seller.products.inherited") }})</i>
                span.hl-value(v-else) {{ def_measure_type_name_get(fiData.def_measure_type) }}
              p {{ $t("seller.products.gov_tax_system") }}&nbsp;
                span.hl-value(v-if="fiData.gov_tax_system_inherit") {{ gov_tax_system_inherited_value }} <i class="t-grey">({{ $t("seller.products.inherited") }})</i>
                span.hl-value(v-else) {{ gov_tax_system_name(fiData.gov_tax_system_id) }}
              p {{ $t("seller.products.gov_tax") }}&nbsp;
                span.hl-value(v-if="fiData.gov_tax_inherit") {{ gov_tax_inherited_value }} <i class="t-grey">({{ $t("seller.products.inherited") }})</i>
                span.hl-value(v-else) {{ gov_tax_name(fiData.gov_tax_id) }}
              p {{ $t("seller.products.currency") }}&nbsp;
                span.hl-value(v-if="fiData.currency_inherit") {{ fiData.currency_inherited_val.t }} <i class="t-grey">({{ $t("seller.products.inherited") }})</i>
                span.hl-value(v-else) {{ currency_name(fiData.def_currency).t }}

              p(v-if="fiData.price_include_tax == null") {{ price_include_tax_name(price_include_tax_inherited_value) }} <i class="t-grey">({{ $t("seller.products.inherited") }})</i>
              p(v-else-if="fiData.price_include_tax == true") {{ $t("seller.products.imported_prices_w_tax") }}
              p(v-else) {{ $t("seller.products.imported_prices_wo_tax") }}
              p.last_updated {{ $t("seller.products.last_saved_update") }}: {{focusedItem.value.data.updated_at}}
              p &nbsp;
              .d-block.text-right.buttons
                button.btn(v-if="!focusedItem.value.root" v-on:click="switchToDeleteMode") {{ $t("buttons.Delete") }}
                button.btn.btn-warning(v-on:click="switchToEditorMode") {{ $t("buttons.edit") }}

          .editor(v-else-if="focused_item_valid && editor_mode")
            div(v-if="!focusedItem.value.root")
              .form-group
                label.t-grey(for="group_name") {{ $t("seller.prodgroups.group_name") }}
                .input-group: input#group_name.form-control(v-model="fiData.group_name")
              .form-group
                label.t-grey(for="group_descr") {{ $t("seller.prodgroups.group_descr") }}
                .input-group: input#group_descr.form-control(v-model="fiData.group_descr")

              .form-group
                .input-group.sort_order
                  label(for="sort_order") {{ $t("seller.prodgroups.sort_order") }}
                  input#sort_order.form-control(v-model.number="fiData.sort_order")

              .form-group(v-if="group_parent_is_active")
                input#group_active(type="checkbox" v-model="fiData.bactive" v-bind:value="true")
                label(for="group_active") &nbsp;{{ $t("seller.prodgroups.group_active") }}
              .form-group(v-else)
                input#group_inactive_inherited(type="checkbox" :checked="true" :disabled="true")
                label(for="group_inactive_inherited") &nbsp;{{ $t("seller.prodgroups.parent_group_inactive") }}
              hr
            .d-block
              p: b {{ $t("seller.products.title_group_opts") }}
              .form-group
                label {{ $t("seller.products.measure_unit") }}
                .d-block.lmargin-1
                  .d-block
                    .input-group
                      .input-group-addon
                        input#measure_type_inherit(type="radio" name="def_measure_type" v-model="fiData.def_measure_type_inherit" v-bind:value="true")
                      label.form-control(for="measure_type_inherit") {{ $t("seller.products.inherit") }} (<i>{{ def_measure_type_inherited_value }}</i>)
                  .d-block
                    .input-group
                      .input-group-addon
                        input#measure_type_select(type="radio" name="def_measure_type" v-model="fiData.def_measure_type_inherit" v-bind:value="false")
                      select.form-control(:disabled="fiData.def_measure_type_inherit" v-model="fiData.def_measure_type")
                        option(v-if="fiData.def_measure_type_inherit" value="0") {{ $t("seller.products.select_measure_unit") }}
                        option(v-for="(value, key) in quantity_measure_units_list" v-bind:value="key") {{ value.rus_full_name }}

              .form-group
                label {{ $t("seller.products.gov_tax_system") }}
                .d-block.lmargin-1
                  .d-block
                    .input-group
                      .input-group-addon
                        input#tax_system_inherit(type="radio" name="gov_tax_system" v-model="fiData.gov_tax_system_inherit" v-bind:value="true")
                      label.form-control(for="tax_system_inherit") {{ $t("seller.products.inherit") }} (<i>{{ gov_tax_system_inherited_value }}</i>)
                  .d-block
                    .input-group
                      .input-group-addon
                        input#tax_system_select(type="radio" name="gov_tax_system" v-model="fiData.gov_tax_system_inherit" v-bind:value="false")
                      select.form-control(:disabled="fiData.gov_tax_system_inherit" v-model="fiData.gov_tax_system_id")
                        option(v-if="fiData.gov_tax_system_inherit" value="0") {{ $t("seller.products.select_gov_tax_system") }}
                        option(v-for="value in gov_tax_systems_list" v-bind:value="value.id") {{ value.name_full }}

              .form-group
                label {{ $t("seller.products.gov_tax") }}
                .d-block.lmargin-1
                  .d-block
                    .input-group
                      .input-group-addon
                        input#gov_tax_inherit(type="radio" name="gov_tax" v-model="fiData.gov_tax_inherit" v-bind:value="true")
                      label.form-control(for="gov_tax_inherit") {{ $t("seller.products.inherit") }}  (<i>{{ gov_tax_inherited_value }}</i>)
                  .d-block
                    .input-group
                      .input-group-addon
                        input#gov_tax_select(type="radio" name="gov_tax" v-model="fiData.gov_tax_inherit" v-bind:value="false")
                      select.form-control(:disabled="fiData.gov_tax_inherit" v-model="fiData.gov_tax_id")
                        option(v-if="fiData.gov_tax_inherit" value="0") {{ $t("seller.products.select_gov_tax") }}
                        option(v-for="value in gov_taxes_list" v-bind:value="value.id") {{ value.name }}

              .form-group
                label {{ $t("seller.products.currency") }}
                .d-block.lmargin-1
                  .d-block
                    .input-group
                      .input-group-addon
                        input#def_currency_inherit(type="radio" name="def_currency" v-model="fiData.currency_inherit" v-bind:value="true")
                      label.form-control(for="def_currency_inherit") {{ $t("seller.products.inherit") }} (<i>{{ fiData.currency_inherited_val.t }}</i>)
                  .d-block
                    .input-group
                      .input-group-addon
                        input#def_currency_select(type="radio" name="def_currency" v-model="fiData.currency_inherit" v-bind:value="false")
                      select.form-control(:disabled="fiData.currency_inherit" v-model="fiData.def_currency")
                        option(v-if="fiData.currency_inherit" value="0") {{ $t("seller.products.select_currency") }}
                        option(v-for="value in currencies_list" v-bind:value="value.id") {{ value.name_ru }} ({{ value.iso_code_name }})

              .form-group
                label {{ $t("seller.products.price_include_tax") }}
                .d-block.lmargin-1
                  .d-block
                    input#price_tax_inherit(type="radio" name="price_include_tax" v-model="fiData.price_include_tax" v-bind:value="null")
                    label(for="price_tax_inherit") {{ $t("seller.products.inherit") }} (<i>{{ price_include_tax_inherited_name(price_include_tax_inherited_value) }}</i>)
                  .d-block
                    input#price_tax_yes(type="radio" name="price_include_tax" v-model="fiData.price_include_tax" v-bind:value="true")
                    label(for="price_tax_yes") {{ $t("seller.products.price_w_tax") }}
                  .d-block
                    input#price_tax_no(type="radio" name="price_include_tax" v-model="fiData.price_include_tax" v-bind:value="false")
                    label(for="price_tax_no") {{ $t("seller.products.price_wo_tax") }}

              p.t-grey * {{ $t("seller.products.totals_taxes_info") }}

            .d-block.text-right.buttons
              button.btn.btn-primary(:disabled="!this_group_changed" v-on:click="storeGroupChangesAndExitEditor") {{ $t("buttons.save") }}
              button.btn.btn-secondary(v-on:click="switchToSummaryMode") {{ $t("buttons.Cancel") }}
            p &nbsp;
            p.last_updated {{ $t("seller.products.last_saved_update") }}: {{focusedItem.value.data.updated_at}}

          .delete-group.border-around(v-else-if="focused_item_valid && delete_mode")
            p.t-red: b {{ $t("seller.prodgroups.group_deletion") }}
            .form-group
              .input-group: input#group_name.form-control(v-model="fiData.group_name" readonly)
            .form-group
              input#delete_empty(type="checkbox" v-model="delData.empty_only" v-bind:value="true")
              label(for="delete_empty") &nbsp;{{ $t("seller.prodgroups.delete_empty_group_only") }}
            .d-block.text-right.buttons
              button.btn.btn-danger(v-if="!focusedItem.value.root" v-on:click="deleteGroup") {{ $t("buttons.Delete") }}
              button.btn.btn-secondary(v-on:click="switchToSummaryMode") {{ $t("buttons.Cancel") }}

      .d-block
        .changes(v-if="groups_changes_exists")
          p: b {{ $t("seller.prodgroups.groups_changes") }}
          ol
            li(v-for="(value, key) in groups_changes")
              span(v-if="value.item") "{{ group_changes_item_initial_name(value.item) }}"
              ul
                li(v-for="(val, key) in value" v-if="key != 'item'") {{ group_change_string(key, val) }}
          .d-block.text-right.buttons
            button.btn.btn-success(v-on:click="sendChangesToServer") {{ $t("buttons.store_save_changes") }}
        .alert.alert-success(role="alert" v-else-if="groups_changes_saved && !groups_changes_exists")
          span {{ $t("seller.prodgroups.groups_changes_saved") }}

</template>

<script>
import Vue from 'vue'
import ProductsGroupsTree from 'components/cabinet/ecommerce/general/seller_products_groups_tree'
import {ProductsGroupsTreeItemCurrentParent, ProductsGroupsTreeItemRootData, ProductsGroupsTreeItemActivity, value_is_not_inherit} from 'store/modules/cabinet/ecommerce/seller/products_groups_functions'

// Для выделенных групп: Удалить, Отключить, Перенести в другую группу, Переместить товары в другую группу

function ProductsGroups_enable_save_button (val, oldVal){
	if((typeof oldVal != 'undefined') && (oldVal != val))this.focusedItem_changed = true;
}


function ProductsGroups_ChangesCompareBuild (arr){
	let changes = {}
	
	for(let i = 0; i < arr.length; i++){
		if(arr[i].anull)arr[i].new_val = null;

		//if((arr[i].new_val == null || arr[i].new_val === 0) && (arr[i].old_val == null || arr[i].old_val === 0))continue;
		//if(arr[i].old_val != arr[i].new_val){
			if(arr[i].type == 'group_name' && (!arr[i].new_val || (arr[i].root && !arr[i].old_val)))continue;
			changes[arr[i].type] = {
				old_val: arr[i].old_val,
				new_val: arr[i].new_val,
			}
		//}
	}
	
	return changes
}


export default {
  data (){return {
	  searchText: '',
      focusedItem: null,
	  focusedItem_changed: false,
	  infopanel_mode: 'summary',
	  fiData: {},
	  newData: {},
	  delData: {},
  }},
  
  
  components: {
	'products-groups-tree': ProductsGroupsTree,
  },
  
  
  methods: {
    
    showSellerGroups (){
      this.$store.dispatch('loadSellerProductsSubGroups')
    },
	
	
	fillFocusedItemData (){
		let item = this.focusedItem
		
		if(item){
			let changed = this.group_changes(item.value.id)

			this.fiData = {
			  group_name:               (changed && changed.group_name) ? changed.group_name.new_val : item.text,
			  group_descr:              (changed && changed.group_descr) ? changed.group_descr.new_val : (item.value.data.descr || item.value.data.pg_descr),
			  sort_order:               (changed && changed.sort_order) ? changed.sort_order.new_val : item.value.data.sort_order,
			  bactive:                  (changed && changed.bactive) ? changed.bactive.new_val : item.value.data.bactive,
			  bactive_parent:           true,
			  def_measure_type_inherit: !value_is_not_inherit((changed && changed.def_measure_type) ? changed.def_measure_type.new_val : item.value.data.def_measure_type),
			  gov_tax_system_inherit:   !value_is_not_inherit((changed && changed.gov_tax_system_id) ? changed.gov_tax_system_id.new_val : item.value.data.gov_tax_system_id),
			  gov_tax_inherit:          !value_is_not_inherit((changed && changed.gov_tax_id) ? changed.gov_tax_id.new_val : item.value.data.gov_tax_id),
			  currency_inherit:         !value_is_not_inherit((changed && changed.def_currency) ? changed.def_currency.new_val : item.value.data.def_currency),
			  currency_inherited_val:   this.currency_inherited_value,
			  
			  def_measure_type:         (changed && changed.def_measure_type) ? changed.def_measure_type.new_val : (item.value.data.def_measure_type <= 0 ? 0 : item.value.data.def_measure_type),
			  def_measure_type_name:    null,
			  def_measure_type_name_id: null,
			  gov_tax_system_id:        (changed && changed.gov_tax_system_id) ? changed.gov_tax_system_id.new_val : (item.value.data.gov_tax_system_id <= 0 ? 0 : item.value.data.gov_tax_system_id),
			  gov_tax_id:               (changed && changed.gov_tax_id) ? changed.gov_tax_id.new_val : (item.value.data.gov_tax_id <= 0 ? 0 : item.value.data.gov_tax_id),
			  def_currency:             (changed && changed.def_currency) ? changed.def_currency.new_val : (item.value.data.def_currency <= 0 ? 0 : item.value.data.def_currency),
			  price_include_tax:        (changed && changed.price_include_tax) ? changed.price_include_tax.new_val : (value_is_not_inherit(item.value.data.price_include_tax) ? item.value.data.price_include_tax : null),
			}
		}
		else this.fiData = {}
	},
	
	
	async treeItemClick (node, item) {
	  if(!this.focusedItem || !this.focusedItem.value || !item.value || (this.focusedItem.value.id != item.value.id)){
		  if(this.editor_mode && this.focusedItem_changed){
			  let answer = await this.$confirmDialog({
				  title: this.$t("messages.save_changes"),
				  content: this.$t("messages.not_saved_before_new_group", {group_name: this.focusedItem.text}),
				  question: this.$t("messages.save_group_changes"),
				  btn_yes_no_cancel: true,
			  })

			  if(answer){
				  // save changes
				  console.log('answer res', true)
				  this.storeGroupChangesAndExitEditor(null)
			  }
			  else if(answer == false){
				  // cancel item click
				  console.log('answer res', false)
				  return
			  }
		  }
		  
		  this.focusedItem = item
		  this.switchToSummaryMode()
	  }
    },
	
	treeItemSelectClick (node, item) {
      // console.log(node.model.text + ' selected !', item)
    },
	
	
	treeItemDropped (node, new_parent, item) {
		console.log('item dropped:', item)
		console.log('new_parent:', new_parent)

		if(item.value && item.value.data){
			this.$store.dispatch('store_changes_SellerProductsGroup', {item_id: item.value.data.id, item, ichanges: {
					new_main_id: {
						old_val: item.value.data.main_group_id,
						new_val: new_parent.value.id,
						old_parent: item.value.initial_parent,
						new_parent
					}
				}
			})
		}
	},
	
	
	storeGroupChangesAndExitEditor (event){
		this.storeGroupChanges(event)
		this.infopanel_mode = 'summary'
	},
	
	
	storeGroupChanges (event){
		let item = this.focusedItem

		let ichanges = ProductsGroups_ChangesCompareBuild([
			{
				type: 'group_name', new_val: this.fiData.group_name,
				old_val: item.value.data.gr_name || item.value.data.pg_name, root: item.value.root
			},
			{
				type: 'group_descr', new_val: this.fiData.group_descr,
				old_val: item.value.data.descr || item.value.data.pg_descr, root: item.value.root
			},
			{
				type: 'sort_order', new_val: this.fiData.sort_order,
				old_val: item.value.data.sort_order
			},
			{
				type: 'bactive', new_val: this.fiData.bactive,
				old_val: item.value.data.bactive
			},
			{
				type: 'def_measure_type', new_val: this.fiData.def_measure_type,
				old_val: item.value.data.def_measure_type, anull: this.fiData.def_measure_type_inherit
			},
			{
				type: 'gov_tax_system_id', new_val: this.fiData.gov_tax_system_id,
				old_val: item.value.data.gov_tax_system_id, anull: this.fiData.gov_tax_system_inherit
			},
			{
				type: 'gov_tax_id', new_val: this.fiData.gov_tax_id,
				old_val: item.value.data.gov_tax_id, anull: this.fiData.gov_tax_inherit
			},
			{
				type: 'def_currency', new_val: this.fiData.def_currency,
				old_val: item.value.data.def_currency, anull: this.fiData.currency_inherit
			},
			{
				type: 'price_include_tax', new_val: this.fiData.price_include_tax,
				old_val: item.value.data.price_include_tax
			},
		])

		if(ichanges.group_name && ichanges.group_name.new_val){
			item.text = ichanges.group_name.new_val
		}

		this.$store.dispatch('store_changes_SellerProductsGroup', {item_id: item.value.data.id, item, ichanges})
	},
	
	
	async deleteGroup (event){
		if(this.delete_mode){
			let item_id = this.focusedItem.value.data.id
			
			let res = await this.$store.dispatch('delete_SellerProductsGroup', {
				id: item_id, parent_id: this.focusedItem.value.data.main_group_id
			})
			
			if(res.meta){
				if(res.meta.success){
					let txt = this.$t('seller.prodgroups.group_deleted_title')
					
					if(res.meta.total_groups_deleted > 1)txt += this.$t('seller.prodgroups.groups_deleted', {count: res.meta.total_groups_deleted});
					if(res.meta.not_contains_products){
						if(res.meta.total_groups_deleted > 1)txt += this.$t('seller.prodgroups.groups_deleted_no_products');
						else txt+=this.$t('seller.prodgroups.group_deleted_no_products');
					}
					else {
						if(res.meta.total_products_deleted)txt += this.$t('seller.prodgroups.group_products_deleted', {count: res.meta.total_products_deleted});
						if(res.meta.images_deleted)txt += this.$t('seller.prodgroups.group_prod_images_deleted', {count: res.meta.images_deleted});
						else txt += this.$t('seller.prodgroups.group_prod_images_skipped');
					}
					this.$messageBox(txt)
					
					let parent_item = ProductsGroupsTreeItemCurrentParent(this.focusedItem, this.$store.state.cabinet.seller.products_groups.changes)
					if(parent_item){
						parent_item.children.every(function(child, idx){
							if(child.value && (child.value.id == item_id)){
								Vue.delete(parent_item.children, idx)
								return false
							}
							return true
						})
					}
					
					this.focusedItem = null
					this.switchToSummaryMode()
				}
			
			} else if(res.errors){
				if(res.errors[0].response && res.errors[0].response.status){
					if(res.errors[0].response.status == 404){
						this.$messageBox(this.$t('seller.prodgroups.group_deleted_already'))
					}
				} else console.log('errors:', res.errors)
			}
		}
	},
	
	
	switchToAddNewMode (event){
		if(!this.addnew_mode){
			let tnow = new Date()
			let thh = tnow.getHours(); if(thh < 10)thh = '0' + thh;
			let tmm = tnow.getMinutes(); if(tmm < 10)tmm = '0' + tmm;
			let tss = tnow.getSeconds(); if(tss < 10)tss = '0' + tss;
			
			this.newData = {
				group_name: this.$t("seller.prodgroups.group_name_new") + ' ' + thh + '' + tmm + '' + tss,
				group_descr: null,
				bactive: false
			}
			this.infopanel_mode = 'addnew'
		}
	},
	
	
	switchToEditorMode (event){
		this.infopanel_mode = 'editor'
	},
	

	switchToDeleteMode (event){
		this.delData.empty_only = true
		this.infopanel_mode = 'delete'
	},
	
	
	switchToSummaryMode (event){
		this.fillFocusedItemData()
		this.focusedItem_changed = false
		if(!this.addnew_mode)this.infopanel_mode = 'summary';
	},
	
	
	gotoGroupProducts (event){
		
	},
	
	
	async createNewGroup(event){
		if(this.addnew_mode){
			let parent_item = (this.focused_item_valid ? this.focusedItem : null)
			this.newData.parent_id = (parent_item ? this.focusedItem.value.data.id : 0)
			
			let res = await this.$store.dispatch('save_new_SellerProductsGroups', {list: [this.newData], parent_item: parent_item})
			if(res && typeof res != 'boolean'){
				if(parent_item && !parent_item.opened)parent_item.opened = true;
				res.setFocus()
				this.switchToEditorMode()
				this.focusedItem_changed = false
			}
		}
	},
	
	
	sendChangesToServer (event){
		this.$store.dispatch('save_changes_SellerProductsGroups')
	},
	
	
	group_change_string (key, info) {
		let text = ''
		
		switch(key){
		  case 'new_main_id':
			text += 'Перенос '
			if(info.old_parent && info.old_parent.value){
				if(info.old_parent.value.id > 0){
					text += 'из "' + info.old_parent.text + '" '
				}
				else if(info.old_parent.value.id <= 0){
					text += 'из корневой группы '
				}
			}
			
			if(info.new_parent && info.new_parent.value){
				if(info.new_parent.value.id > 0){
					text += 'в "' + info.new_parent.text + '"'
				}
				else if(info.new_parent.value.id <= 0){
					text += 'в корневую группу'
				}
			}
			break
		  case 'group_name':
		    text += 'Переименование в "' + info.new_val + '"'
			break
		  case 'group_descr':
		    text += 'Описание: ' + (info.old_val ? ('"' + info.old_val + '"') : 'пустое')  + ' => "' + info.new_val + '"'
			break
		
		  case 'sort_order':
		    text += 'Порядок сортировки: "' + ((info.old_val != null) ? info.old_val  : 'отсутствует')  + '" => "' + ((info.new_val != null) ? info.new_val : 'отсутствует') + '"'
			break
		  case 'bactive':
		    text += (info.new_val ? "Включение активности группы" : "Отключение активности группы")
			break
		  case 'def_measure_type':
		    text += this.$t("seller.products.measure_unit") + ' ' + (value_is_not_inherit(info.old_val) ? ('"' + this.def_measure_type_name_now(info.old_val) + '"') : 'наследуемая')  + ' => ' + (value_is_not_inherit(info.new_val) ? ('"' + this.def_measure_type_name_now(info.new_val) + '"') : 'наследуемая')
			break
		  case 'gov_tax_system_id':
		    text += this.$t("seller.products.gov_tax_system") + ' ' + (value_is_not_inherit(info.old_val) ? ('"' + this.gov_tax_system_name(info.old_val) + '"') : 'наследуемая')  + ' => ' + (value_is_not_inherit(info.new_val) ? ('"' + this.gov_tax_system_name(info.new_val) + '"') : 'наследуемая')
			break
		  case 'gov_tax_id':
		    text += this.$t("seller.products.gov_tax") + ' ' + (value_is_not_inherit(info.old_val) ? ('"' + this.gov_tax_name(info.old_val) + '"') : 'наследуемая')  + ' => ' + (value_is_not_inherit(info.new_val) ? ('"' + this.gov_tax_name(info.new_val) + '"') : 'наследуемая')
			break
		  case 'def_currency':
		    text += this.$t("seller.products.currency") + ' ' + (value_is_not_inherit(info.old_val) ? ('"' + this.currency_name(info.old_val).t + '"') : 'наследуемая')  + ' => ' + (value_is_not_inherit(info.new_val) ? ('"' + this.currency_name(info.new_val).t + '"') : 'наследуемая')
			break
		  case 'price_include_tax':
		    text += 'Учёт налога в ценах: "' + ((info.old_val != null) ? this.price_include_tax_name(info.old_val) : 'наследуется')  + '" => "' + ((info.new_val != null) ? this.price_include_tax_name(info.new_val) : 'наследуется') + '"'
			break
		
		}
		
		return text
	},
	
	gov_tax_name (res){
		if(res){
			res = this.$store.state.cabinet.seller.GovTaxes.find(function(item){return (item.id == res)})
			if(res)return res.name;
		}
		
		return this.$t('messages.undefined')
	},
	
	gov_tax_system_name (res){
		if(res){
			res = this.$store.state.cabinet.seller.GovTaxSystems.find(function(item){return (item.id == res)})
			if(res)return res.name;
		}
		
		return this.$t('messages.undefined')
	},
	
	currency_name (res){
		if(res){
			res = this.$store.state.cabinet.ecommerce.Currencies.find(function(item){return (item.id == res)})
			if(res)return {id: res.id, t: (res.name_ru + ', ' + res.iso_code_name)};
		}
		
		return {id: null, t: this.$t('messages.undefined')}
	},
	
	
	async retrieve_def_measure_type_name (id){
		if(this.fiData.def_measure_type_name_id != id){
			this.fiData.def_measure_type_name_id = id
			
			let res = await this.$store.dispatch('getProductQuantityMeasureUnitById', id)
			
			if(this.fiData.def_measure_type_name_id == id){
				res = (res ? (res.rus_full_name) : this.$t('messages.undefined'))
				if(this.def_measure_type_name != res)this.def_measure_type_name = res
			}
		}
	},

	
	measure_type_name_existing (id){
		let res = this.$store.getters.DataArray_getItemById({node: 'measure_units', id})
		return ((res && res.length) ? (res[0].rus_full_name) : null)
	},
	
	def_measure_type_name_now (id){
		let res = this.measure_type_name_existing(id)
		return (res ? res : this.$t('messages.undefined'))
	},

	
	def_measure_type_name_get (id){
		let res = this.measure_type_name_existing(id)
		if(res)return res;
		
		this.def_measure_type_name = this.$t('messages.undefined')
		this.retrieve_def_measure_type_name(id)
		return this.def_measure_type_name
	},
	

	price_include_tax_inherited_name(res){
		if(res != null){
			return this.$t(res ? "seller.products.price_w_tax" : "seller.products.price_wo_tax")
		}
		
		return this.$t('messages.undefined')
	},
	
	
	price_include_tax_name(res){
		if(res != null){
			return this.$t(res ? "seller.products.imported_prices_w_tax" : "seller.products.imported_prices_wo_tax")
		}
		
		return this.$t('messages.undefined')
	},


	group_changes_exist (item_id){
		return (this.$store.state.cabinet.seller.products_groups.changes_exists && this.$store.state.cabinet.seller.products_groups.changes && this.$store.state.cabinet.seller.products_groups.changes[item_id])
	},
	
	
	group_changes (item_id){
		if(this.$store.state.cabinet.seller.products_groups.changes_exists && this.$store.state.cabinet.seller.products_groups.changes){
			return this.$store.state.cabinet.seller.products_groups.changes[item_id]
		}
		else return null
	},
	
	
	is_applicable_or_absent_SellerSystemTask (name, time_to_check){
		return (!this.$store.state.cabinet.seller.SysTasks[name] || (
			this.$store.state.cabinet.seller.SysTasks[name].enabled && (
				!this.$store.state.cabinet.seller.SysTasks[name].enabled_at || (time_to_check >= this.$store.state.cabinet.seller.SysTasks[name].enabled_at)
			)
		))
	},
	
	newly_group_hidden_children (item){
		return (!item.value.child_num && item.value.data && item.value.data.tree_changed && !item.value.children_searched && this.is_applicable_or_absent_SellerSystemTask('groups_tree_updates', item.value.data.epoch_updated_at))
	},
	
	group_changes_item_initial_name (item){
		if(!item.value.root && item.value.id && this.$store.state.cabinet.seller.products_groups.changes[item.value.id].group_name && this.$store.state.cabinet.seller.products_groups.changes[item.value.id].group_name.old_val){
			return this.$store.state.cabinet.seller.products_groups.changes[item.value.id].group_name.old_val
		} else return item.text
	},

  },
  
  
  created (){
	  this.showSellerGroups()
  },
  
  
  computed: {
	data_read_success (){
		return (this.$store.state.cabinet.seller.products_groups.data && this.$store.state.cabinet.seller.products_groups.data.length > 0)
	},
	
	editor_mode (){
		return (this.infopanel_mode == 'editor')
	},

	addnew_mode (){
		return (this.infopanel_mode == 'addnew')
	},
	
	summary_mode (){
		return (this.infopanel_mode == 'summary')
	},
	
	delete_mode (){
		return (this.infopanel_mode == 'delete')
	},
	
	focused_item_valid (){
		return this.focusedItem && this.focusedItem.value && this.focusedItem.value.data
	},
	
	groups_tree (){
		return (this.data_read_success ? this.$store.state.cabinet.seller.products_groups.data : null)
	},
	
	groups_changes (){
		return this.$store.state.cabinet.seller.products_groups.changes
	},
	
	groups_changes_exists (){
		return ((this.$store.state.cabinet.seller.products_groups.changes_exists && this.$store.state.cabinet.seller.products_groups.changes) ? true : false)
	},
	
	groups_changes_saved (){
		return this.$store.state.cabinet.seller.products_groups.changes_saved_notification
	},
	
	currencies_list (){
		return this.$store.state.cabinet.ecommerce.Currencies
	},
	
	quantity_measure_units_list (){
		return this.$store.getters.DataArray_getItemsFull({node: 'measure_units'})
	},
	
	gov_taxes_list (){
		return this.$store.state.cabinet.seller.GovTaxes
	},
	
	gov_tax_systems_list (){
		return this.$store.state.cabinet.seller.GovTaxSystems
	},
	
	this_group_changed (){
		return this.focusedItem_changed
	},
	
	group_parent_is_active(){
		return(this.bactive_parent = ProductsGroupsTreeItemActivity(
			this.focusedItem.value.id,
			this.focusedItem.value.initial_parent,
			'bactive',
			this.$store.state.cabinet.seller.products_groups.changes_exists ? this.$store.state.cabinet.seller.products_groups.changes : null,
		))
	},
	
	def_measure_type_inherited_value (){
		let res = ProductsGroupsTreeItemRootData(
			this.focusedItem.value.id,
			this.focusedItem.value.initial_parent,
			'def_measure_type', 'ProdMeasureUnit',
			this.$store.state.cabinet.seller.products_groups.changes_exists ? this.$store.state.cabinet.seller.products_groups.changes : null,
			this.$store.state.cabinet.seller.Defaults
		)
		return this.def_measure_type_name_get(res)
	},

	
	gov_tax_inherited_value (){
		let res
		
		if(this.$store.state.cabinet.seller.GovTaxes){
			res = ProductsGroupsTreeItemRootData(
				this.focusedItem.value.id,
				this.focusedItem.value.initial_parent,
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
				this.focusedItem.value.id,
				this.focusedItem.value.initial_parent,
				'gov_tax_system_id', 'GovTaxSystem',
				this.$store.state.cabinet.seller.products_groups.changes_exists ? this.$store.state.cabinet.seller.products_groups.changes : null,
				this.$store.state.cabinet.seller.Defaults
			)
		}

		return this.gov_tax_system_name(res)
	},
	
	
	price_include_tax_inherited_value (){
		let res = ProductsGroupsTreeItemRootData(
			this.focusedItem.value.id,
			this.focusedItem.value.initial_parent,
			'price_include_tax', 'PriceIncTax',
			this.$store.state.cabinet.seller.products_groups.changes_exists ? this.$store.state.cabinet.seller.products_groups.changes : null,
			this.$store.state.cabinet.seller.Defaults
		)
		
		return res
	},
	
	
	currency_inherited_value (){
		let res
		
		if(this.$store.state.cabinet.ecommerce.Currencies){
			res = ProductsGroupsTreeItemRootData(
				this.focusedItem.value.id,
				this.focusedItem.value.initial_parent,
				'def_currency', 'Currency',
				this.$store.state.cabinet.seller.products_groups.changes_exists ? this.$store.state.cabinet.seller.products_groups.changes : null,
				this.$store.state.cabinet.seller.Defaults
			)
		}

		if(res){
			res = this.$store.state.cabinet.ecommerce.Currencies.find(function(item){return (item.id == res)})
			if(res)return {id: res.id, t: (res.name_ru + ', ' + res.iso_code_name)};
		}
		
		return {id: null, t: this.$t('messages.undefined')}
	},
	
	
	new_group_parent (){
		return ((this.focused_item_valid && this.fiData && this.fiData.group_name) ? this.fiData.group_name : this.$t('seller.prodgroups.all_groups_name'))
	},
	
	group_products_path (){
		let path = this.$route.fullPath
		if(path[path.length - 1] != '/')path += '/'
		
		path += ((this.focused_item_valid) ? this.focusedItem.value.id : 0) + '/products/'
		return {path}
	}

  },
  
  watch: {
	  //'$route': 'showSellerGroups',
	  
	  'fiData.group_name': ProductsGroups_enable_save_button,
	  'fiData.group_descr': ProductsGroups_enable_save_button,
	  'fiData.sort_order': ProductsGroups_enable_save_button,
	  'fiData.bactive': ProductsGroups_enable_save_button,
	  
	  'fiData.def_measure_type_inherit': ProductsGroups_enable_save_button,
	  'fiData.def_measure_type': ProductsGroups_enable_save_button,
	  'fiData.currency_inherit': ProductsGroups_enable_save_button,
	  'fiData.def_currency': ProductsGroups_enable_save_button,
	  'fiData.price_include_tax': ProductsGroups_enable_save_button,
	  'fiData.gov_tax_system_inherit': ProductsGroups_enable_save_button,
	  'fiData.gov_tax_system_id': ProductsGroups_enable_save_button,
	  'fiData.gov_tax_inherit': ProductsGroups_enable_save_button,
	  'fiData.gov_tax_id': ProductsGroups_enable_save_button,
  },
  
}
</script>
<style>
.tree, *, body {
	background: #ff0000 !important;
}
</style>