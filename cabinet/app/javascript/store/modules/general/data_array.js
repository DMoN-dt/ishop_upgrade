import Vue from 'vue'
import {DataSlicesArray, getDataArraySlice} from './data_slices_array'


function buildApiFuncName (context, name_str){
	if(!name_str)return null;
	
	let call_api_func = context.rootState.App.$api
	
	name_str.split('.').every(function(item){
		if(call_api_func[item]){call_api_func = call_api_func[item]; return true;}
		
		call_api_func = null
		return false
	})
	
	return call_api_func
}



export default {
  state: {
	nodes: {},
  },


  mutations: {
	  DATA_ARRAY_SUB_NODE_ID_SET_DEFAULT (state, {node, id}){
		if(!state.nodes[node])state.nodes[node] = {data: {}}
		state.nodes[node].defaultSubNodeId = id
	  },


	  DATA_ARRAY_FILL (state, {node, subnode_id, erase, data_array, data_start, data_len, data_total_cnt}){
		if(data_array){
			if(!state.nodes[node])state.nodes[node] = {
				data: {},
				dataOrder: null,
				defaultSubNodeId: 0,
			}
			
			if(!state.nodes[node].data[subnode_id])state.nodes[node].data[subnode_id] = {}
			if(!state.nodes[node].data[subnode_id].data || erase)state.nodes[node].data[subnode_id].data = new DataSlicesArray()
			
			state.nodes[node].data[subnode_id].data.add_slice(data_array, data_start, data_array.length)
			
			if(typeof data_total_cnt != 'undefined')state.nodes[node].data[subnode_id].total_cnt = data_total_cnt
		}
		else if(erase)state.nodes[node].data[subnode_id] = null;
	  },
	  
	  
	  DATA_ARRAY_FILL_FULL_DATA (state, {node, id, item, data, meta}){
		  if(!state.nodes[node])state.nodes[node] = {data: {}, defaultSubNodeId: 0}
		  if(!state.nodes[node].fullData)state.nodes[node].fullData = {};
		  
		  state.nodes[node].fullData[id + ''] = data
		  
		  if(typeof item == 'object'){
			  item._full_data = data
			  if(meta && meta.data_names){
				  meta.data_names.forEach(function(aname){
					  item['_' + aname] = meta[aname]
				  })
			  }
		  }
		  else {
			  if(meta && meta.data_names){
				  meta.data_names.forEach(function(aname){
					  data['_' + aname] = meta[aname]
				  })
			  }
		  }
	  },
	  
	  
	  DATA_ARRAY_ADD_FULL_DATA (state, {node, data, unique_col}){
		  if(!state.nodes[node])state.nodes[node] = {data: {}, defaultSubNodeId: 0}
		  if(!state.nodes[node].fullData)state.nodes[node].fullData = {};
		  if(!unique_col)unique_col = 'id'

		  if(data.length){
			  data.forEach(function(new_item){
				  if(Object.keys(state.nodes[node].fullData).every(function(exist_id){
					if(unique_col == 'id')return !(state.nodes[node].fullData[exist_id].id == new_item.id || Number(exist_id) == new_item.id)
					return !(state.nodes[node].fullData[exist_id][unique_col] == new_item[unique_col])
				  })){
					  state.nodes[node].fullData[new_item.id + ''] = new_item
				  }
			  })
		  }
	  },
  },


  actions: {
	async DataArray_setDefaultSubNodeId (context, {node, id}){
		await context.commit('DATA_ARRAY_SUB_NODE_ID_SET_DEFAULT', {node, id})
	},
	
	
	async DataArray_DefaultSubNodeId (context, node){
		return (context.state.nodes[node] ? context.state.nodes[node].defaultSubNodeId : null)
	},
	  
  
  // Получить актуальный список стран и заполнить data
	async DataArray_loadData (context, {api_func, node, subnode_id, start, maxcnt, erase, order, get_total, params} = {}){
		if(typeof erase == 'undefined')erase = false;

		let call_api_func = buildApiFuncName(context, api_func)

		if(call_api_func){
			const response = await call_api_func(context, {start, maxcnt, order, get_total, subnode_id, params})
			if(response.result && response.result.data){
				if(typeof response.result.data != 'undefined'){
					let existDataOrder = (context.state.nodes[node] ? context.state.nodes[node].dataOrder : null)
					if((!existDataOrder && order) || (existDataOrder && !order) || (JSON.stringify(existDataOrder) !== JSON.stringify(order))){
						erase = true
						if(!context.state.nodes[node])context.state.nodes[node] = {data: {}, defaultSubNodeId: 0}
						context.state.nodes[node].dataOrder = order
					}
					
					await context.commit('DATA_ARRAY_FILL', {
						node,
						subnode_id,
						data_array: response.result.data,
						data_total_cnt: response.result.meta.data_total_cnt,
						data_start: start,
						erase
					})
				}
			}
		}
	},
  
  
	async DataArray_getDataSlice (context, {node, subnode_id, start, maxcnt, order, get_total, params, api_func_load} = {}){
		if(!node)return null;
		
		if(typeof subnode_id == 'undefined' || subnode_id == null)subnode_id = (context.state.nodes[node] ? context.state.nodes[node].defaultSubNodeId : 0);
		if((typeof start == 'undefined') || (start <= 0))start = 0;
		if((typeof maxcnt == 'undefined') || (maxcnt <= 0))maxcnt = 25;
		
		let data_arr
		//this.getters.sortedByField(data_arr, 'name')
		
		if(context.state.nodes[node]){
			let existDataOrder = context.state.nodes[node].dataOrder
			if((!existDataOrder && !order) || (existDataOrder && order && (JSON.stringify(existDataOrder) === JSON.stringify(order)))){
				data_arr = getDataArraySlice(context.state.nodes[node].data, subnode_id, start, maxcnt, order)
			} else data_arr = null;
		} else data_arr = null;

		if(data_arr === null){
			await context.dispatch('DataArray_loadData', {node, subnode_id, start, maxcnt, order, get_total, params, api_func: api_func_load})
			if(context.state.nodes[node])data_arr = getDataArraySlice(context.state.nodes[node].data, subnode_id, start, maxcnt, order, true)
		}
		return data_arr
	},
  
  
	async DataArray_getItemFullData (context, {node, id, item, api_func, params, skip_search} = {}){
		if(!node || (typeof id == 'undefined') || (id == null))return null;
		
		if(!skip_search && context.state.nodes[node] && context.state.nodes[node].fullData && context.state.nodes[node].fullData[id + '']){
			return context.state.nodes[node].fullData[id + '']
		}
		
		let call_api_func = buildApiFuncName(context, api_func)
		if(call_api_func){
			const response = await call_api_func(context, id, params)
			if(response.result && response.result.data){
				await context.commit('DATA_ARRAY_FILL_FULL_DATA', {node, id, item, params, data: response.result.data, meta: response.result.meta})
				return response.result.data
			}
		}
		return null
	},
  },


  getters: {
	  //sortedByField(data_array, field_name, order = 'asc'){
		//console.log('sortedByField', data_array)
		//return (order == 'asc') ? data_array.sort((a, b) => a[field_name] > b[field_name]) : data_array.sort((a, b) => a[field_name] < b[field_name]);
	  //}
	  
	DataArray_getItemFullById: (state) => ({node, id}) => {
		if(state.nodes[node] && state.nodes[node].fullData && state.nodes[node].fullData[id + '']){
			return [ state.nodes[node].fullData[id + ''] ]
		}
		return null
	},
	
	DataArray_getItemById: (state) => ({node, id}) => {
		if(state.nodes[node] && state.nodes[node].fullData && state.nodes[node].fullData[id + '']){
			return [ state.nodes[node].fullData[id + ''] ]
		}
		return null
	},
	
	DataArray_getItemsFull: (state) => ({node}) => {
		if(state.nodes[node] && state.nodes[node].fullData){
			return state.nodes[node].fullData
		}
		return null
	}
  }

}