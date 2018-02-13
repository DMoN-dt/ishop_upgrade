export function DataSlicesArray(){
	this.data = null
}

DataSlicesArray.prototype.add_slice = function(data_array, start, len) {
	let fully_affected_array_keys = [], start_array_key, end_array_key
	let end = start + len

	if(!len || len < 0 || start < 0)return;
	if(!this.data)this.data = {};
	
	Object.keys(this.data).every(key => {
		let keyn = Number(key)
		
		// Поиск блока, содержащего начало вставки
		if((keyn <= start) && (this.data[key] && (keyn + this.data[key].length) >= start)){
			
			if((key + this.data[key].length) >= end){// замена данных внутри текущего блока и выход из цикла
				this.data[key] = this.data[key].slice(0, start - keyn).concat(data_array).concat(this.data[key].slice(end - keyn))
				len = 0
				return false
			}
			else {// не все данные в одном этом блоке
				if(keyn == start)fully_affected_array_keys.push(key);
				else start_array_key = key;
			}
		}
		
		// Поиск блоков, полностью охватываемых вставкой внутри неё
		else if((keyn > start) && (keyn < end) && ((keyn + this.data[key].length) <= end)){
			fully_affected_array_keys.push(key)
		}
		
		// Поиск блока, содержащего окончание вставки
		else if((keyn <= end) && (this.data[key] && (keyn + this.data[key].length) >= end)){
			end_array_key = key
		}
		
		return true
	})

	// Вставка данных
	if(len){
		if(end_array_key){
			let end_keyn = Number(end_array_key)

			if(end_keyn != end)data_array = data_array.concat(this.data[end_array_key].slice(end - end_keyn))
			else data_array = data_array.concat(this.data[end_array_key])
		
			fully_affected_array_keys.push(end_array_key)
		}

		fully_affected_array_keys.every(key => {
			delete this.data[key]
			return true
		})
		fully_affected_array_keys = null
		
		if(start_array_key){
			let start_keyn = Number(start_array_key)
			if(start != start_keyn)this.data[start_array_key] = this.data[start_array_key].slice(0, start - start_keyn).concat(data_array);
			else this.data[start] = data_array;
		} 
		else this.data[start] = data_array;
	}
}

DataSlicesArray.prototype.get_slice = function(start, len, any_existing_range = false) {
	let ret_arr, fully_affected_array_keys = [], start_array_key, end_array_key
	let end = start + len, len_exist = 0

	if(!len || len < 0 || start < 0)return [];
	if(!this.data)this.data = {};
	
	Object.keys(this.data).every(key => {
		let keyn = Number(key)
		
		// Поиск блока, содержащего начало запроса
		if((keyn <= start) && (this.data[key] && (keyn + this.data[key].length) >= start)){

			if((keyn + this.data[key].length) >= end){// выдача запрошенных данных изнутри текущего блока и выход из цикла
				ret_arr = this.data[key].slice(start - keyn, end)
				len_exist = len
				return false
			}
			else {// не все данные в одном этом блоке
				if(keyn == start){
					fully_affected_array_keys.push(key)
					len_exist += this.data[key].length
				}
				else {
					start_array_key = key
					len_exist += this.data[key].length - (start - keyn)
				}
			}
		}
		
		// Поиск блоков, полностью охватываемых запросом внутри него
		else if((keyn > start) && (keyn < end) && ((keyn + this.data[key].length) <= end)){
			fully_affected_array_keys.push(key)
			len_exist += this.data[key].length
		}
		
		// Поиск блока, содержащего окончание запроса
		else if((keyn <= end) && (this.data[key] && (keyn + this.data[key].length) >= end)){
			end_array_key = key
			len_exist += end - keyn
		}
		
		return true
	})
	
	// Выдача данных
	if(!ret_arr){
		if((len_exist >= len) || (any_existing_range && (len_exist > 0))){
			if(start_array_key){
				ret_arr = this.data[start_array_key].slice(start - Number(start_array_key))
			} else {
				ret_arr = []
			}
			
			fully_affected_array_keys.every(key => {
				ret_arr = ret_arr.concat(this.data[key])
				return true
			})
			fully_affected_array_keys = null
			
			if(end_array_key)ret_arr = ret_arr.concat(this.data[end_array_key].slice(0, end - Number(end_array_key)));
		}
		else return null;
	}

	return ret_arr
}


export function getDataArraySlice (data_array, data_key, start, maxcnt, order, any_existing_range = false){
	if(data_array && data_array[data_key]){
		if((data_array[data_key].total_cnt === 0) || (start >= data_array[data_key].total_cnt))return {data: [], total: data_array[data_key].total_cnt};
		
		if(data_array[data_key].data){
			if((start + maxcnt) > data_array[data_key].total_cnt)maxcnt = data_array[data_key].total_cnt - start;
			
			let data = data_array[data_key].data.get_slice(start, maxcnt, any_existing_range)
			if(data === null)return null;
			return {data, total: data_array[data_key].total_cnt}
		}
	}
	return null
}