# CHECK the Seller's Limitation to Add/Dleete and Update

class Api::V1::SellerProductsGroupsController < Api::ApiSecuredController
	before_action -> {authorize_request! false, true, :user }, :only => [:scopes_required]
	before_action -> {authorize_request! false, true, {any: [:seller, :ecom]} }, :only => [:index, :group_parents, :group_parents_tree]
	before_action -> {authorize_request! true, true, {all: [:gwrite], any: [:seller, :ecom]} }, :only => [:create, :update_groups, :destroy]
	
	before_action :authenticate_and_authorize_user_action,             :except => [:scopes_required, :destroy]
	before_action :authenticate_and_authorize_user_action_and_object,  :only   => [:destroy, :group_parents, :group_parents_tree]
	after_action  :verify_authorized, :except => [:scopes_required]
	
	def index
		pparams = params.permit(:parent_group_id)
		pparams[:parent_group_id] = ((pparams[:parent_group_id].present? && pparams[:parent_group_id].numeric?) ? pparams[:parent_group_id].to_i : nil)
		
		data = {products_groups: SellerProductsGroup.query_nodes_with_depth(@seller_id, pparams[:parent_group_id])}
		data[:seller_sys_tasks] = {}
		
		if(pparams[:parent_group_id].nil?)
			# gen_measurement_units
			data[:gov_tax_systems] = GenGovTaxSystem.select('tax_system_code as id, name, name_full').where(country_code: Seller.gov_taxes_country).find_all
			data[:gov_taxes] = GenGovTax.select('tax_code as id, name, name_full, tax_rate').where(country_code: Seller.gov_taxes_country).find_all
			data[:currencies] = GenCurrency.select('iso_code as id, iso_code_name, name as name_ru, name_eng as name_en').all
			data[:prod_measure_units] = GenMeasurementUnit.myself_general('rus', true).order('top_sort_order asc, rus_full_name asc').find_all #PRODUCT_MEASURE_TYPE
			
			data[:seller] = {
				def_currency: Seller.default_currency,
				def_gov_tax_system: Seller.default_gov_tax_system_id,
				def_gov_tax: Seller.default_gov_tax_id,
				def_price_w_tax: GenSetting.default_price_include_tax?,
				def_show_price_w_tax: GenSetting.default_show_price_with_tax?,
				def_show_price_as_is: GenSetting.default_show_price_as_is?,
				def_show_price_nochange: GenSetting.default_price_with_tax_nochange?,
				def_prod_measure_unit: GenSetting.default_lot_measure_type,
			}
		end

		task_update_groups_tree = SellerSystemTask.task_get('update_groups_tree', @seller_id)
		if(task_update_groups_tree)
			data[:seller_sys_tasks][:groups_tree_updates] = {
				enabled: task_update_groups_tree.state, enabled_at: task_update_groups_tree.enabled_at.to_i
			}
		end
		
		render_result(data: data)
	end
	
	
	def create
		pparams = params.permit(:list => [])
		data = {success: false}

		if(params[:list].present?)
			time_start = Time.now
			
			avail_columns = {
				'group_name'    => {required: true, field: 'gr_name', limit: 150},
				'group_descr'   => {field: 'descr', limit: 70},
				'bactive'       => {required: true, default: true},
				'parent_id'     => {required: true, field: 'main_group_id', default: 0},
				'prod_group_id' => {required: true, default: 0},
			}
			
			# Collect Parent SellerProductsGroups -> ProductsGroups (in OnlineStore mode)
			if(marketplace_is_shop?)
				cnt_total = 0
				seller_parent_prodgroups = nil
				seller_parent_ids = []
				
				params[:list].each do |group_to_add|
					break if(cnt_total >= 100)
					
					ok = true
					avail_columns.each do |param_name, avail_col_info|
						next if(avail_col_info[:exclude])
						if(group_to_add[param_name].nil? && avail_col_info[:required] && avail_col_info[:default].nil?)
							ok = false
							break
						end
					end
					
					if(ok)
						pid = ((group_to_add['parent_id'].blank?) ? 0 : group_to_add['parent_id'])
						seller_parent_ids << pid if(!seller_parent_ids.include?(pid))
					end
					cnt_total += 1
				end
				
				if(seller_parent_ids.present?)
					seller_parent_prodgroups = SellerProductsGroup.select('id, prod_group_id').where(seller_id: @seller_id, id: seller_parent_ids).find_all
				end
			end
			
			
			# Insert Groups
			data[:list] = []
			cnt_total = 0
			cnt_inserted = 0
			main_groups_ids = []
			insert_values = []
			insert_values_str = nil
			avail_columns_str = nil
			list_cnt = params[:list].length
			
			params[:list].each do |group_to_add|
				break if(cnt_total >= 100)
				
				item = {}
				
				if(group_to_add['uid'].is_a?(String) && group_to_add['uid'].numeric?)
					item[:uid] = group_to_add['uid'].to_i
				elsif(group_to_add['uid'].is_a?(Integer))
					item[:uid] = group_to_add['uid']
				end
				
				item[:idx] = cnt_total if(item[:uid].nil?)
				
				# Collect validated fields to store in DB
				fields_to_add = {}
				if(!available_fields_fetch(group_to_add, avail_columns, fields_to_add))
					item[:bad_params] = true
					cnt_total += 1
					next
				end
				
				# Add the same ProductsGroup (in OnlineStore mode)
				if(marketplace_is_shop?)
					if((fields_to_add['main_group_id'] > 0) && seller_parent_prodgroups.present?)
						def_main_id = seller_parent_prodgroups.select{|im| im.id == fields_to_add['main_group_id']}.first[:prod_group_id]
					else
						def_main_id = 0
					end
					
					pg = ProductsGroup.create({
						gr_name: fields_to_add['gr_name'],
						b_show:  fields_to_add['bactive'],
						def_main_id: def_main_id
					})
					
					if(pg.present?)
						fields_to_add['prod_group_id'] = pg.id
						fields_to_add['gr_name'] = nil
						fields_to_add['descr'] = nil
					end
				end
				
				cnt_total += 1
				fields_to_add['seller_id'] = @seller_id
				fields_to_add['tree_changed'] = true
				
				# Insert new SellerProductsGroup to DB
				if(list_cnt <= 3)
					spg = SellerProductsGroup.create(fields_to_add)
					if(spg.present?)
						cnt_inserted += 1
						item[:id] = spg.id
						item[:updated_at] = spg.updated_at
						
						# Set the Tree Is Changed to Parent group
						SellerProductsGroup.connection.update(
							"UPDATE #{SellerProductsGroup.quoted_table_name} SET #{SellerProductsGroup.sanitize_changes_for_assignment({tree_changed: true, updated_at: spg.updated_at}, nil)} WHERE ((id = #{spg.main_group_id}) AND (tree_changed IS NOT TRUE) AND (seller_id = #{@seller_id}))"
						)
					end
					
					data[:list] << item
					
				else
					fields_to_add['updated_at'] = fields_to_add['created_at'] = Time.now
					main_groups_ids << fields_to_add['main_group_id']
					
					if(insert_values_str.nil?)
						insert_values_str = '?,' * fields_to_add.keys.length
						insert_values_str = insert_values_str[0,insert_values_str.length-1]
					end
					
					insert_values << SellerProductsGroup.sanitize_insert_values(insert_values_str, fields_to_add.values)
					
					if(insert_values.length >= 10) or (cnt_total >= list_cnt) or (cnt_total >= 100)
						if(avail_columns_str.nil?)
							avail_columns_str = fields_to_add.keys.join(",")
						end

						if(SellerProductsGroup.connection.insert(
							"INSERT INTO #{SellerProductsGroup.quoted_table_name} (#{avail_columns_str}) VALUES #{insert_values.map{|val| "(#{val})"}.join(",")}"
						))
							cnt_inserted += insert_values.length
							
							# Set the Tree Is Changed to Parent group
							SellerProductsGroup.connection.update(
								"UPDATE #{SellerProductsGroup.quoted_table_name} SET #{SellerProductsGroup.sanitize_changes_for_assignment({tree_changed: true, updated_at: spg.updated_at}, nil)} WHERE ((id = ANY(VALUES #{main_groups_ids.map{|val| "(#{val})"}.join(",")})) AND (tree_changed IS NOT TRUE) AND (seller_id = #{@seller_id}))"
							)
							
							main_groups_ids = []
						end

						insert_values = []
					end
					
					data[:list] << item if(item[:bad_params])
				end
			end
			
			SellerSystemTask.task_set_or_add('update_groups_tree', @seller_id, {state: true, reason_count: cnt_inserted, enabled_at: time_start}) if(cnt_inserted != 0)
			
			data[:inserted] = cnt_inserted
			data[:success]  = (cnt_inserted == cnt_total)
		end

		render_result(data: data)
	end
	
	
	def update_groups
		all_success = nil
		parent_group_changes_cnt = 0
		main_groups_ids = []
		groups_changed_measure_type = []
		result_changes = {}
		
		if(params[:changes].present?)
			time_start = Time.now
			
			avail_change_types = {
				'new_main_id' => {null: false, col: 'main_group_id'},
				'group_name' => {null: false},
				'group_descr' => {null: true, default: ''},
				'sort_order' => {null: true},
				'bactive' => {null: false, default: false},
				'def_measure_type' => {null: true},
				'gov_tax_system_id' => {null: false},
				'gov_tax_id' => {null: false},
				'def_currency' => {null: false},
				'price_include_tax' => {null: true}
			}
			
			params[:changes].each do |item_id, data|
				item_id = item_id.to_i if(item_id.is_a?(String) && item_id.numeric?)
				
				if(item_id.is_a?(Integer) && data.present?)
					data.reject!{|k,v| avail_change_types[k].nil?}
					
					if(data['group_name'].present? or data['group_descr'].present?)
						spg = SellerProductsGroup.eager_load(:products_group).where(id: item_id).first
						next if(spg.blank?)
						
						if(marketplace_is_shop?)
							changes = {}
							
							if(defined?(spg.products_group))
								if(data['group_name'].present? && spg.products_group.gr_name != data['group_name']['new_val'])
									changes[:gr_name] = data['group_name']['new_val']
								end
								
								if(data['group_descr'].present? && spg.products_group.gr_name != data['group_descr']['new_val'])
									changes[:descr] = data['group_descr']['new_val']
								end
								
								if(data['bactive'].present? && spg.products_group.b_show != data['bactive']['new_val'])
									changes[:b_show] = data['bactive']['new_val']
								end
							end

							if(changes.present? && spg.prod_group_id.present?)
								changes['updated_at'] = Time.now
								success = (ProductsGroup.connection.update(
									"UPDATE #{ProductsGroup.quoted_table_name} SET #{SellerProductsGroup.sanitize_changes_for_assignment(changes, ProductsGroup.table_name)} WHERE id = #{spg.prod_group_id}"
								) ? true : false)
								
								if(all_success.nil?)
									all_success = success
								elsif(all_success && !success)
									all_success = false
								end
								
								result_changes[item_id] = {ok: success}
							end
							
						else
							data['gr_name'] = data['group_name']
							data['descr']   = data['group_descr']
						end
						
						data.reject!{|k,v| ((k == 'group_name') or (k == 'group_descr'))}
					end
					
					next if(data.blank?)
					
					# Save SellerProductsGroup changes to DB
					changes = {}
					
					data.each do |param_name, values|
						if(values['new_val'].nil? && (avail_change_types[param_name][:null] != true))
							values['new_val'] = ((avail_change_types[param_name][:default].nil?) ? 0 : avail_change_types[param_name][:default])
						end
						
						changes[ ((avail_change_types[param_name][:col].blank?) ? param_name : avail_change_types[param_name][:col]) ] = values['new_val']
					end
					
					
					changes_def_measure_type = changes.has_key? 'def_measure_type'

					if(!changes['main_group_id'].nil? or changes_def_measure_type)
						spg = SellerProductsGroup.where(id: item_id).first if(spg.nil?)
						next if(spg.blank?)
						
						if(!changes['main_group_id'].nil?)
							main_groups_ids += [spg.main_group_id, changes['main_group_id'].to_i]
						end

						if(changes_def_measure_type)
							measure = {to: changes['def_measure_type']}
							
							if(spg.def_measure_type.nil? or spg.def_measure_type == 0)
								mut = spg.inherited_measure_unit_type
								measure[:from_inh] = mut if(mut)
							else
								measure[:from] = spg.def_measure_type
							end
							
							changed_measure_type_info = {group: item_id, measure: measure}
						end
					end

					changes['updated_at'] = Time.now
					n = SellerProductsGroup.connection.update(
						"UPDATE #{SellerProductsGroup.quoted_table_name} SET #{SellerProductsGroup.sanitize_changes_for_assignment(changes, nil)} WHERE ((id = #{item_id}) AND (seller_id = #{@seller_id}))"
					)
					
					success = (n ? true : false)
					if(success)
						parent_group_changes_cnt += n if(!changes['main_group_id'].nil?)
						groups_changed_measure_type << changed_measure_type_info if(changes_def_measure_type)
					end
					
					if(all_success.nil?)
						all_success = success
					elsif(all_success && !success)
						all_success = false
					end
					
					result_changes[item_id] = {ok: success}
				end
			end
		end
		
		if(parent_group_changes_cnt != 0)
			SellerSystemTask.task_set_or_add('update_groups_tree', @seller_id, {state: true, reason_count: parent_group_changes_cnt, enabled_at: time_start}) 
			
			if(main_groups_ids.length != 0)
				SellerProductsGroup.connection.update(
					"UPDATE #{SellerProductsGroup.quoted_table_name} SET #{SellerProductsGroup.sanitize_changes_for_assignment({tree_changed: true}, nil)} WHERE ((id = ANY(VALUES #{main_groups_ids.map{|val| "(#{val})"}.join(",")})) AND (tree_changed IS NOT TRUE) AND (seller_id = #{@seller_id}))"
				)
			end
		end
		
		if(groups_changed_measure_type.present?)
			SellerSystemTask.task_set_or_add('update_products_inherited', @seller_id, {
				state: true, reason_count: groups_changed_measure_type.length, enabled_at: time_start,
				reason_list: groups_changed_measure_type.map{|x| (x.blank? ? nil : x[:group])},
				reason_params: groups_changed_measure_type
			})
			
			SellerSystemTask.task_execute('update_products_inherited', @seller_id, current_user)
		end
		
		
		render_result(data: {
			success: all_success,
			changes: result_changes
		})
	end
	
	
	# DELETE /:id/
	# -----------
	# Deletes a group with/without subgroups and products
	#
	# RETURN VALUES:
	# data: empty
	# meta:
	#  not_contains_products: true (or absent)
	#  total_products_deleted: total number of products deleted
	#  total_groups_deleted: total number of groups and underlying subgroups deleted
	#  images_deleted: number of not shared products images deleted
	#
	def destroy
		pparams = params.permit(:delete_entire, :destroy_products) #:parent_id
		
		pparams[:delete_entire] = false if(pparams[:delete_entire].blank?)
		pparams[:destroy_products] = false if(pparams[:destroy_products].blank?)
		
		res_meta = {success: false}
		time_start = Time.now
		
		## Ensure this is not a random query and frontend knows main_group_id of this group :)
		#
		#if(pparams[:parent_id].present?)
		#	pparams[:parent_id] = pparams[:parent_id].to_i if(pparams[:parent_id].is_a?(String) && pparams[:parent_id].numeric?)
		#	if(@seller_products_group.main_group_id == pparams[:parent_id])
				
				child_nodes = @seller_products_group.build_children_nodes_list
				
				if(child_nodes.present?)
					child_nodes.push(@seller_products_group.id)
					seller_groups_condition = "ANY(VALUES #{child_nodes.map{|val| "(#{val})"}.join(",")})"
				else
					child_nodes = [@seller_products_group.id]
					seller_groups_condition = @seller_products_group.id.to_s
				end
				
				products_exists = SellerProduct.exists?(seller_id: @seller_id, seller_group_id: child_nodes)
				
				if(pparams[:delete_entire])
					# Delete products of a group and subgroups
					if(products_exists)
						res_meta[:total_products_deleted] = SellerProductsGroup.connection.delete(
							"DELETE FROM #{SellerProduct.quoted_table_name} WHERE ((seller_id = #{@seller_id}) AND (seller_group_id = #{seller_groups_condition}))"
						)
					end
					
					# Delete a group and subgroups
					res_meta[:total_groups_deleted] = delete_group_and_subgroups(seller_groups_condition)
					
					# Finally Delete products pictures and photos from DB and Filesystem
					if(products_exists)
						res_meta[:images_deleted] = 0
						ProductsImage.where(
							"#{ProductsImage.table_name}.id IN ( SELECT DISTINCT UNNEST(photo_ids) FROM #{SellerProduct.quoted_table_name} WHERE ((seller_id = #{@seller_id}) AND (seller_group_id = #{seller_groups_condition}) AND (photo_ids IS NOT NULL) AND (array_length(photo_ids,1) != 0)) ) AND (b_shared IS NOT TRUE)"
						).find_each do |img|
							img.destroy_with_imagefile # Destroy Image File
							res_meta[:images_deleted] += 1
						end
					else
						res_meta[:not_contains_products] = true
					end
				
				else
					if(products_exists)
						render_error('non-empty', :ok) and return
					else
						res_meta[:total_groups_deleted]  = delete_group_and_subgroups(seller_groups_condition)
						res_meta[:not_contains_products] = true
					end
				end
				
				res_meta[:success] = true
		#	end
		#end
		
		SellerSystemTask.task_set_or_add('update_groups_tree', @seller_id, {state: true, reason_count: res_meta[:total_groups_deleted], enabled_at: time_start}) if(res_meta[:total_groups_deleted] != 0)
		
		render_result(data: nil, meta: res_meta)
	end
	
	
	# POST /:id/parents
	# -----------------
	# Query for parents of the group and the group itself
	#
	def group_parents
		parents = SellerProductsGroup.find_parents_tree(@seller_id, @seller_products_group.id).find_all
		groups = parents.to_a
		groups += SellerProductsGroup.about_myself_general(@seller_id, @seller_products_group.id)
		groups.uniq!
		render_result(data: {products_groups: groups})
	end
	
	
	# POST /:id/parents_tree
	# ----------------------
	# Query for parents of the group with their children
	#
	def group_parents_tree
		parents = SellerProductsGroup.find_parents_tree(@seller_id, @seller_products_group.id).find_all
		groups = parents.to_a
		
		parents.each do |pgroup|
			groups += SellerProductsGroup.query_nodes_with_depth(@seller_id, pgroup[:id])
		end
		groups.uniq!
		render_result(data: {products_groups: groups})
	end
	
	
	def scopes_required
		pparams = params.permit(:method, :req_action)
		
		# Mime::Type.unregister :json
		# Mime::Type.register "application/json", :json, %w( text/x-json application/jsonrequest application/vnd.api+json )
		# Mime::Type.lookup_by_extension("json")
		# parsers.select{ |mt, p| mt.symbol == content_mime_type.symbol }
		# logger.warn({:tmime_json => Mime::Type.lookup_by_extension("json")}.to_s)
		
		render_result(data: {scopes: general_scopes_list(current_user, PROJECT_RESTRICTED_AREA_ECOMMERCE_SELLERS, pparams[:req_action], pparams[:method])})
	end
	
	### ========================================================= PRIVATE ================================================================
	### ==================================================================================================================================
	private

	
	def authenticate_and_authorize_user_action
		authenticate_user! # Devise authentication. It must be called after protect_from_forgery to CSRF-token work properly.
		pparams = params.permit(:seller_id)
		
		roles = nil
		if(action_name == 'update_groups')
			roles = [:objorg_seller]
		end
		
		return if(!authorize_seller_access(pparams[:seller_id], roles))
		
		authorize SellerProductsGroup # Pundit authorization.
	end
	
	
	def authenticate_and_authorize_user_action_and_object
		# authenticate_user! # Devise authentication. It must be called after protect_from_forgery to CSRF-token work properly.
		pparams = params.permit(:seller_id, :id)

		return if(!authorize_seller_access(pparams[:seller_id]))
		
		if(pparams[:id].present? && pparams[:id].numeric?)
			if((@seller_products_group = SellerProductsGroup.where(id: pparams[:id].to_i, seller_id: @seller_id).first).blank?)
				render :nothing => true, :status => :not_found and return
			end
		end
		
		#if(pparams[:item_uid].present?)
		#	@item_safe_uid = pparams[:item_uid][0,SAFE_UID_MAX_LENGTH]
		#	item_id = SellerProductsGroup.from_safe_uid(@item_safe_uid)
		#	if(item_id.nil? or (@products_group = SellerProductsGroup.where(id: item_id, seller_id: @seller.id).first).blank?)
		#		return
		#	end
		#end
		#
		authorize @seller_products_group # Pundit authorization.
	end
	
	
	def available_fields_fetch (group_to_add, avail_columns, fields_to_add)
		avail_columns.each do |param_name, avail_col_info|
			next if(avail_col_info[:exclude])
			field_name = ((avail_col_info[:field].present?) ? avail_col_info[:field] : param_name)
			
			if(group_to_add[param_name].nil?)
				if(avail_col_info[:required])
					if(avail_col_info[:default].nil?)
						return false
					else
						fields_to_add[field_name] = avail_col_info[:default]
					end
				else
					fields_to_add[field_name] = nil
				end
				
			else
				fields_to_add[field_name] = ((avail_col_info[:limit].nil?) ? group_to_add[param_name] : group_to_add[param_name][0, avail_col_info[:limit]])
			end
		end
		
		return true
	end
	
	
	def delete_group_and_subgroups (seller_groups_condition)
		return SellerProductsGroup.connection.delete(
			"DELETE FROM #{SellerProductsGroup.quoted_table_name} WHERE ((seller_id = #{@seller_id}) AND (id = #{seller_groups_condition}))"
		)
	end
	
end