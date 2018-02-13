<template>
  <v-jstree :data="data" :initialFocusedId="initialFocused"
    :show-checkbox="showCheckbox" :multiple="multiple" :allow-batch="allowBatch" :whole-row="wholeRow" :draggable="draggable" :size="size"
    @need-parents="needParentsTree" @item-click="treeItemFocusClick" @item-toggle="treeItemToggle"
    @item-dropped="treeItemDropped" @item-select="treeItemSelectClick"></v-jstree>
</template>

<script>
import Vue from 'vue'
import VJstree from 'vue-jstree-my'

export default {
  name: 'products-groups-list',
  props: {
    data: {type: Array},
	initialFocused: {type: Number},
	
	size: {type: String, validator: value => ['large', 'small'].indexOf(value) > -1},
	showCheckbox: {type: Boolean, default: false},
    wholeRow: {type: Boolean, default: false},
    noDots: {type: Boolean, default: false},
    multiple: {type: Boolean, default: false},
    allowBatch: {type: Boolean, default: false},
	draggable: {type: Boolean, default: false},
  },
  
  data (){return {
	  focusedGroup: null,
  }},
  
  components: {
	VJstree
  },
  
  created (){
  },
  
  methods: {
	treeItemFocusClick (node, item) {
	  if(!this.focusedGroup || !this.focusedGroup.value || !item.value || (this.focusedGroup.value.id != item.value.id)){
		  if((!item.value.child_num) && (item.children.length > 0)){
			item.value.child_num = item.children.length
		  }

		  if(this.newly_group_hidden_children(item))this.fetchHiddenSubgroups(item);
		  this.focusedGroup = item
	  }
	  
	  this.$emit('item-click', node, item)
	},
	
	
	async treeItemToggle (node, item, skip_child_num = false) {
	  if(item && (typeof item.value != 'undefined') && (typeof item.value.id != 'undefined') && (skip_child_num || (item.value.child_num > 0))){
		  
		if(!item.value.is_toggled){
			item.value.is_toggled = true
			
			if((item.children.length == 0) || (item.children[0].loading && item.children[0].disabled && !item.value.is_loading)){
				item.value.is_loading = true

				let result = await this.$store.dispatch('loadSellerProductsSubGroups', {parent_group_id: item.value.id})
				if(result){
					if(result.data){
						let children
						if((result.data.length == 1) && (result.data[0].children.length > 0)){
							children = result.data[0].children
						} else children = result.data;
						
						item.children = []
						
						if(item.hasOwnProperty('addChildren'))item.addChildren(children);
						else console.error("item hasn't addChildren property !");
						
						item.children.forEach(function(child){child.value.initial_parent = item;})
					}
				} else if(item.children.length){
					item.children[0].text = 'Загрузка... Ошибка.'
				}
				
				item.value.is_loading = false
			}
			
			if(item.children.length != 0){
				item.children.forEach(function(child){
					if(this.newly_group_hidden_children(child))this.fetchHiddenSubgroups(child);
				}, this)
			}
			
			item.value.is_toggled = false
		}
	  }
	  
	  this.$emit('item-toggle', node, item, skip_child_num)
	},
	
	
	treeItemDropped (node, new_parent, item) {
		this.$emit('item-dropped', node, new_parent, item)
	},
	
	
	treeItemSelectClick (node, item) {
		this.$emit('item-select', node, item)
	},
	
	
	groupsTreeInsertAbsentChildren (item, new_groups_tree, root){
		if(item.value.id == new_groups_tree.value.id){
			if(new_groups_tree.children){
				let groups_add = []
				new_groups_tree.children.forEach(function(new_child){
					if(item.children.every(function(elem){
						return (elem.value.id != new_child.value.id)
					})){// not existing child
						groups_add.push(new_child)
					} else {
						// child is exist, go inside
						if(!item.children.every(function(elem){
							return this.groupsTreeInsertAbsentChildren(elem, new_child)
						}, this)){
							item.opened = true
						}
					}
				}, this)
				
				if(groups_add.length){
					if(item.children[0].loading){
						item.children = []
					}
					item.addChildren(groups_add)
					item.opened = true
				}
			}
			return false
		
		} else if(root && item.value.root){
			return this.groupsTreeInsertAbsentChildren (item, {
				value: {id: item.value.id},
				children: [new_groups_tree]
			}, false)
		}
		return true
	},
	
	
	async needParentsTree (group_id){
		let result = await this.$store.dispatch('loadSellerProductsGroupParents', {group_id})
		if(result && result.data){
			let new_groups_tree = result.data;
			if(this.data){
				let groups_add = []
				new_groups_tree.every(function(new_elem){
					if(this.data.every(function(data_elem){
						return this.groupsTreeInsertAbsentChildren(data_elem, new_elem, true)
					}, this)){
						groups_add.push(new_elem)
					}
				}, this)
				
				if(groups_add.length)this.data.concat(groups_add);
			}
		}
	},
	
	
	newly_group_hidden_children (item){
		return (!item.value.child_num && item.value.data && item.value.data.tree_changed && !item.value.children_searched && this.is_applicable_or_absent_SellerSystemTask('groups_tree_updates', item.value.data.epoch_updated_at))
	},
	
	
	is_applicable_or_absent_SellerSystemTask (name, time_to_check){
		return (!this.$store.state.cabinet.seller.SysTasks[name] || (
			this.$store.state.cabinet.seller.SysTasks[name].enabled && (
				!this.$store.state.cabinet.seller.SysTasks[name].enabled_at || (time_to_check >= this.$store.state.cabinet.seller.SysTasks[name].enabled_at)
			)
		))
	},
	
	
	async fetchHiddenSubgroups (item = this.focusedGroup){
		await this.treeItemToggle(null, item, true)
		Vue.set(item.value, 'children_searched', true)
		
		if(item.children.length > 0){
			item.value.child_num = item.children.length;
		}
	},

  },
  
  watch: {
	  //'data' (newVal, oldVal){
		//  if(!oldVal && newVal && newVal.length && this.initialFocused){
		//  }
	  //},
  },
}
</script>