export function ProductsGroupsTreeItemCurrentParent (item, changes){
	if(item.value && item.value.id){
		let item_id = item.value.id
	
		if(changes && changes[item_id] && changes[item_id].new_main_id && changes[item_id].new_main_id.new_parent){
			return changes[item_id].new_main_id.new_parent
		}
		
		return item.value.initial_parent
	}
	return null
}


export function ProductsGroupsTreeItemRootData (item_id, initial_parent, data_key, seller_def_key, changes, seller_data = null, skip_nulls_only = false, max_depth = 10){
	if(changes && changes[item_id] && changes[item_id].new_main_id && changes[item_id].new_main_id.new_parent){
		initial_parent = changes[item_id].new_main_id.new_parent
	}
	
	if(initial_parent && initial_parent.value){
		if(changes && changes[initial_parent.value.id] && changes[initial_parent.value.id][data_key]){
			if(value_is_not_inherit(changes[initial_parent.value.id][data_key].new_val)){
				return changes[initial_parent.value.id][data_key].new_val
			}
		}
		
		if(initial_parent.value.data && (typeof initial_parent.value.data[data_key] != 'undefined')){
			if(value_is_not_inherit(initial_parent.value.data[data_key])){
				return initial_parent.value.data[data_key]
			}
		}
		
		if(initial_parent.value.id && max_depth > 0){
			return ProductsGroupsTreeItemRootData(initial_parent.value.id, initial_parent.value.initial_parent, data_key, seller_def_key, changes, seller_data, skip_nulls_only, max_depth - 1)
		}
	}

	if(seller_data){
		return seller_data[seller_def_key]
	}
	
	return null
}


export function ProductsGroupsTreeItemActivity (item_id, initial_parent, data_key, changes, max_depth = 10){
	if(changes && changes[item_id] && changes[item_id].new_main_id && changes[item_id].new_main_id.new_parent){
		initial_parent = changes[item_id].new_main_id.new_parent
	}
	
	if(initial_parent && initial_parent.value){
		if(changes && changes[initial_parent.value.id] && changes[initial_parent.value.id][data_key]){
			if(!changes[initial_parent.value.id][data_key].new_val)return false;
		}
		
		if(initial_parent.value.data){
			if((typeof initial_parent.value.data[data_key] != 'undefined') && (initial_parent.value.data[data_key] != null)  && (initial_parent.value.data[data_key] !== 0)){
				if(!initial_parent.value.data[data_key])return false;
			}
		}
		
		if(initial_parent.value.id && max_depth > 0){
			return ProductsGroupsTreeItemActivity(initial_parent.value.id, initial_parent.value.initial_parent, data_key, changes, max_depth - 1)
		}
	}
	return true
}

export function value_is_not_inherit (value, negative_allowed = true){
	return (
		((typeof value == 'integer') && (value != null) && (value != 0) && (negative_allowed || (value > 0))) ||
		((typeof value == 'boolean') && (value != null)) ||
		((typeof value != 'undefined') && value)
	)
}