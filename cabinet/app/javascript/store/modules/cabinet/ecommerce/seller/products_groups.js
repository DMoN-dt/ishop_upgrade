import Vue from 'vue'

function tree_nodes(tree, tree_map, root_id, item_data = null, parent_item = null, max_depth = 10){
	let tree_item

	if((typeof root_id != 'undefined') && (root_id != null) && tree_map[root_id]){
		if(tree_map[root_id].main){
			tree_item = {
				id: root_id,
				text: tree_map[root_id].main.gr_name || tree_map[root_id].main.pg_name,
				value: {id: Number(root_id), main_id: tree_map[root_id].main.main_group_id, data: tree_map[root_id].main},
			}
			
			if(tree_map[root_id].root)tree_item.value.root = true;
		}
		else if(item_data){
			tree_item = {
				id: item_data.id,
				text: item_data.gr_name || item_data.pg_name,
				value: {id: Number(item_data.id), data: item_data}
			}
		}
		else {tree_item = {value: {id: root_id}};}

		if(tree_map[root_id].children){
			if(max_depth > 0){
				let arr = {data: []}
			
				Object.keys(tree_map[root_id].children).map(function(child_id, index) {
					tree_nodes(arr, tree_map, child_id, tree_map[root_id].children[child_id], tree_item, max_depth - 1)
				})
				
				tree_item.children = arr.data
				tree_item.value.child_num = arr.data.length
			}
			else {
				tree_item.children_depth_limit = true
			}
		}
	}
	else if(item_data){
		tree_item = {
			id: item_data.id,
			text: item_data.gr_name || item_data.pg_name,
			value: {id: Number(item_data.id), data: item_data},
		}
	}
	else console.log('ROOT:', root_id)
	
	if(tree_item){
		if(item_data){
			if(!tree_item.value){tree_item.value = {}}
			if(!tree_item.value.data)tree_item.value.data = item_data
			
			if(item_data.child_num && item_data.child_num > 0){
				if(!tree_item.children){
					tree_item['children'] = [{
						text: 'Загрузка...', disabled: true, loading: true, value: {}
					}]
				}
				
				tree_item.value.child_num = item_data.child_num
			}
		}
		
		if(typeof tree_item.children == 'undefined')tree_item.children = [];
		
		if(parent_item)tree_item.value.initial_parent = parent_item;
		
		tree_item.opened = false
		tree.data.push(tree_item)
	}
}


function ProductsGroupsToTree (_this, products_groups, force_root_id = null){
	if(products_groups && (products_groups.length != 0)){
		let tree_map = {}, tree = {data: []}
		let root_id = null, root_item = null, max_children = 0, id_with_max_children = null, main_of_id_with_max_children = null
		
		// Create Map array of Main <-> Children
		for(let i = 0; i < products_groups.length; i++){
			if((typeof products_groups[i].main_group_id == 'undefined') || (products_groups[i].main_group_id <= 0)){
				if(typeof tree_map[products_groups[i].id] == 'undefined'){
					tree_map[products_groups[i].id] = {}
				}
				tree_map[products_groups[i].id]['main'] = products_groups[i]
			}

			if(typeof tree_map[products_groups[i].main_group_id] == 'undefined'){
				tree_map[products_groups[i].main_group_id] = {}
			}
			
			if(typeof tree_map[products_groups[i].main_group_id].children == 'undefined'){
				tree_map[products_groups[i].main_group_id].children = {}
			}
			tree_map[products_groups[i].main_group_id].children[products_groups[i].id] = products_groups[i]
			
			if(force_root_id == null){
				if(products_groups[i].main_group_id <= 0){
					if((root_id == null) || (root_id > products_groups[i].main_group_id)){
						root_id = products_groups[i].main_group_id;
						root_item = products_groups[i];
					}
				}
				
				if((root_id == null) && (typeof products_groups[i].child_num != 'undefined') && (max_children < products_groups[i].child_num)){
					max_children = products_groups[i].child_num
					id_with_max_children = products_groups[i].id
					main_of_id_with_max_children = products_groups[i].main_group_id
				}
			}
		}

		// Create Tree
		if(force_root_id != null){root_id = force_root_id; root_item = null;}
			
		if(root_id != null){
			while(root_id < 0){
				if((typeof tree_map[root_id] == 'undefined') || (typeof tree_map[root_id]['main'] == 'undefined')){
					root_id++;
					if(typeof tree_map[root_id] != 'undefined'){
						if(typeof tree_map[root_id]['main'] != 'undefined')break;
						
						let len = Object.keys(tree_map[root_id]).length
						if((len > 1) || ((len == 1) && (root_item != null) && (typeof tree_map[root_id][root_item.id] == 'undefined'))){
							tree_map[root_id]['main'] = root_item;
							tree_map[root_id]['root'] = true;
							break;
						}
					}
				}
			}
			
			tree_nodes(tree, tree_map, root_id)
		}
		else if(id_with_max_children){
			if((typeof main_of_id_with_max_children != 'undefined') && (main_of_id_with_max_children != null) && (tree_map[main_of_id_with_max_children])){
				id_with_max_children = main_of_id_with_max_children
			}
			
			tree_nodes(tree, tree_map, id_with_max_children)
		}
		
		if(tree.data.length > 0){
			tree.data.forEach(function(item){
				item.opened = true
				
				if(!item.text && ((typeof item.value == 'undefined') || (item.value && (item.value.id <= 0)))){
					item.text = _this.$t('seller.prodgroups.all_groups_name')
				}
			})
		}
		
		return tree
	} else {
		return {data: null}
	}
}

function ProductsGroupsTreeFindById (data, id){
	if(!data || id <= 0 || !data.length)return null;
	
	let found_item = null

	data.every(function(item){
		if(item.value && (item.value.id == id)){
			found_item = item
			return false
		}
		
		if(item.children && (item.children.length > 0)){
			found_item = ProductsGroupsTreeFindById(item.children, id)
			if(found_item)return false;
		}
		
		return true
	}, this)
	
	return found_item
}


const state = {
    data: null,
	data_success: false,
	changes: {},
	changes_exists: false,
	changes_saved_notification: false,
}


const mutations = {
  FILL_SELLER_PRODUCTS_GROUPS(state, tree){
    if(typeof tree != 'undefined'){
		state.data = tree.data
		state.data_success = true
	}
  },
  
  STORE_CHANGES_SELLER_PRODUCTS_GROUP(state, {item_id, item, ichanges}){
	Object.keys(ichanges).map(function(key, index){
		let equal = (
			((ichanges[key].new_val == null || ichanges[key].new_val === 0) && (ichanges[key].old_val == null || ichanges[key].old_val === 0)) ||
			(ichanges[key].old_val == ichanges[key].new_val)
		)
		
		if(!equal){
			if(!state.changes[item_id])Vue.set(state.changes, item_id, {});
			if(!state.changes[item_id].item && item)Vue.set(state.changes[item_id], 'item', item);
			
			Vue.set(state.changes[item_id], key, ichanges[key]);
		}
		else if(state.changes[item_id] && state.changes[item_id][key]){
			Vue.delete(state.changes[item_id], key)
			
			let cnt = Object.keys(state.changes[item_id]).length
			if(cnt == 0 || (cnt == 1 && typeof state.changes[item_id].item != 'undefined')){
				Vue.delete(state.changes, item_id);
				if(Object.keys(state.changes).length == 0){state.changes_exists = false; return;}
			}
		}
	})

	if(!state.changes_exists){
		state.changes_exists = (Object.keys(state.changes).length > 0)
		state.changes_saved_notification  = false
	}
  },
}


const actions = {
  // Получить актуальный массив групп с определённой глубиной вложенности и заполнить data
  async loadSellerProductsSubGroups (context, {seller_id, parent_group_id} = {}){
	if(typeof seller_id == 'undefined')seller_id = context.rootState.cabinet.seller.SellerId;
	if(typeof parent_group_id == 'undefined')parent_group_id = null;
	
	const response = await context.rootState.App.$api.seller.prodgroups.fetchList(context, seller_id, parent_group_id)
	if(response.result && response.result.data){
		if(typeof response.result.data.products_groups != 'undefined'){
			let tree = ProductsGroupsToTree(context.rootState.App, response.result.data.products_groups, parent_group_id)
			
			if((parent_group_id == null) || (parent_group_id <= 0))context.commit('FILL_SELLER_PRODUCTS_GROUPS', tree);
			
			if(response.result.data.currencies)context.dispatch('setCurrencies', response.result.data.currencies);
			if(response.result.data.prod_measure_units)context.dispatch('setProductQuantityMeasureUnits', response.result.data.prod_measure_units);
			if(response.result.data.gov_tax_systems){
				context.dispatch('setSellerGovTaxes', {
					gov_tax_systems: response.result.data.gov_tax_systems,
					gov_taxes: response.result.data.gov_taxes
				});
			}
			if(response.result.data.seller){
				context.dispatch('setSellerDefaults', response.result.data.seller);
			}
			if(response.result.data.seller_sys_tasks){
				context.dispatch('setSellerSystemTask', {task_name: 'groups_tree_updates', task_data: response.result.data.seller_sys_tasks.groups_tree_updates});
			}
			
			return tree;
			
		} else return null
	} else return null
  },

  
  store_changes_SellerProductsGroup (context, data){
	  context.commit('STORE_CHANGES_SELLER_PRODUCTS_GROUP', data)
  },

  async save_changes_SellerProductsGroups (context){
	  if(state.changes_exists){
		let ival, groups_changes = {}
		
		Object.keys(state.changes).map(function(key, index) {
			if(!isNaN(key)){
				groups_changes[key] = {}
				
				ival = state.changes[key]
				Object.keys(ival).map(function(ikey, index) {
					if(ikey != 'item'){
						groups_changes[key][ikey] = {old_val: ival[ikey].old_val, new_val: ival[ikey].new_val}
					}
				})
			}
		})
		
		const mode = this.state.cabinet.CabinetGeneralInfo.mode
		
		const response = await this.state.App.$api.seller.prodgroups.update(context, groups_changes)
		if(response.result && response.result.data){
			state.changes_saved_notification = true
			
			if(response.result.data.success){
				state.changes_saved_success = true
				
				if(response.result.data.changes){
					Object.keys(state.changes).map(function(key, index) {
						if(!isNaN(key) && response.result.data.changes[key]){
							
							if(response.result.data.changes[key].ok){
								
								ival = state.changes[key]
								Object.keys(ival).map(function(ikey, index) {
									if((ikey == 'group_name') || (ikey == 'group_descr')){
										if(mode == 'estore'){
											if(ikey == 'group_name')ival.item.value.data.pg_name = ival[ikey].new_val;
											else ival.item.value.data.pg_descr = ival[ikey].new_val;
										} else {
											if(ikey == 'group_name')ival.item.value.data.gr_name = ival[ikey].new_val;
											else ival.item.value.data.descr = ival[ikey].new_val;
										}
									}
									else ival.item.value.data[ikey] = ival[ikey].new_val;
								})
							} else {
								ival = response.result.data.changes[key]
								Object.keys(ival).map(function(ikey, index) {
									if(ival[ikey].ok){
										state.changes[key].item.value.data[ikey] = state.changes[key][ikey].new_val
									}
								})
							}
							
						}
					})
				}
				
				state.changes_exists = false
				state.changes = {}
			}
		}
		else {
			console.log('errors:', response.errors)
		}
	  }
  },
  
  
  async save_new_SellerProductsGroups (context, {list, parent_item}){
	  const response = await this.state.App.$api.seller.prodgroups.createNew(context, list)
	  if(response.result && response.result.data){
		  const mode = this.state.cabinet.CabinetGeneralInfo.mode
		  
		  if(response.result.data.inserted > 0){
			  if((typeof parent_item != 'undefined') && (parent_item != null)){
				  if((typeof parent_item.children == 'undefined') || (parent_item.children == null))parent_item.children = []
				  
				  if(response.result.data.list && response.result.data.list.length > 0){
					  let new_item, data
					  response.result.data.list.forEach(function(inserted_item){
						  if((typeof inserted_item.idx != 'undefined') && (inserted_item.idx != null) && (inserted_item.idx < list.length)){
							  new_item = list[inserted_item.idx]
						  } else new_item = null
						  
						  if(new_item){
							  data = {
								  id: inserted_item.id,
								  bactive: new_item.bactive,
								  updated_at: inserted_item.updated_at,
								  sort_order: null,
								  def_measure_type: null,
								  gov_tax_system_id: null,
								  gov_tax_id: null,
								  def_currency: null,
								  price_include_tax: null,
							  }
							  
							  if(mode == 'estore'){
								  data.pg_name = new_item.group_name;
								  data.pg_descr = new_item.group_descr;
							  }
							  else {
								  data.gr_name = new_item.group_name;
								  data.descr = new_item.group_descr;
							  }
							  
							  parent_item.addChild({
								id: data.id,
								text: new_item.group_name,
								value: {
									id: data.id, data,
									initial_parent: parent_item
								},
								children: [],
							  })
						  }
					  })
					  
					  return ((parent_item.children.length > 0) ? parent_item.children[parent_item.children.length-1] : true)
				  }
			  }
			  
			  return true
		  }
	  }
	  else {
		console.log('errors:', response.errors)
	  }
	  
	  return false
  },
  
  async delete_SellerProductsGroup (context, {id, parent_id}){
	  const response = await this.state.App.$api.seller.prodgroups.destroy(context, id, {parent_id})
	  if(response.result){
		  return {meta: response.result.meta, errors: response.result.errors}
	  } else {
		  // Обработать 404 ошибку - группа не существует, возможно уже удалена
		  return {errors: response.errors}
	  }
  },
  
  // Получить массив всех родительских групп для конкретной группы
  async loadSellerProductsGroupParents (context, {seller_id, group_id}){
	if((typeof group_id == 'undefined') || (group_id == null))return;
	if(typeof seller_id == 'undefined')seller_id = context.rootState.cabinet.seller.SellerId;
	
	const response = await context.rootState.App.$api.seller.prodgroups.fetchParentsTree(context, group_id, seller_id)
	if(response.result && response.result.data){
		if(typeof response.result.data.products_groups != 'undefined'){
			return ProductsGroupsToTree(context.rootState.App, response.result.data.products_groups)
		} else return null
	} else return null
  },
  
  async getSellerProductsGroupById (context, {seller_id, group_id}){
	if((typeof group_id == 'undefined') || (group_id == null))return;
	if(typeof seller_id == 'undefined')seller_id = context.rootState.cabinet.seller.SellerId;
	
	let found_item = null
	
	if(context.state.data_success && (seller_id == context.rootState.cabinet.seller.SellerId)){// Try to Find in Existing Tree
		found_item = ProductsGroupsTreeFindById(context.state.data, group_id)
	}
	
	if(!found_item){// Query API for information
		const response = await context.rootState.App.$api.seller.prodgroups.fetchParents(context, group_id, seller_id)
		if(response.result && response.result.data && (typeof response.result.data.products_groups != 'undefined')){
			let tree = ProductsGroupsToTree(context.rootState.App, response.result.data.products_groups)
			found_item = ProductsGroupsTreeFindById(tree, group_id)
		}
	}
	
	return found_item
  },
}


export default {
  data (){return {data: null}},
  state,
  mutations,
  actions,
  // getters, modules, plugins, strict
  // computed: {}
}