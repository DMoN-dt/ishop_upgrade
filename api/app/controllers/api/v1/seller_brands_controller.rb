class Api::V1::SellerBrandsController < Api::ApiSecuredController
	before_action -> {authorize_request! false, true, :user }, :only => [:scopes_required]
	before_action -> {authorize_request! false, true, {any: [:seller, :ecom]} }, :only => [:index, :show]
	before_action -> {authorize_request! true, true, {all: [:gwrite], any: [:seller, :ecom]} }, :only => [:create, :update, :destroy]
	
	before_action :authenticate_and_authorize_user_action,             :except => [:scopes_required, :destroy]
	before_action :authenticate_and_authorize_user_action_and_object,  :only   => [:show, :destroy]
	after_action  :verify_authorized, :except => [:scopes_required]
	
	def index
		qparams = query_pagination_params(100, ['updated_at', 'name'])
		
		data = {}
		meta = {}
		
		brands_query = SellerBrand.where(seller_id: @seller_id)

		meta[:data_total_cnt] = brands_query.count if(qparams[:get_total])
		data = brands_query.for_cabinet_list_select_lite.order(qparams[:order_str]).limit(qparams[:max_limit]).offset(qparams[:offset_num])

		render_result(data: data, meta: meta)
	end
	
	
	def create
		pparams = params.permit(:list => [])
		data = {success: false}

		if(params[:list].present?)
			time_start = Time.now
			
			# data[:inserted] = cnt_inserted
			# data[:success]  = (cnt_inserted == cnt_total)
		end

		render_result(data: data)
	end
	

	# GET /:id/
	# -----------
	# Show a brand.
	#
	# RETURN VALUES:
	# data: All brand's fields
	#
	def show
		data = {}
		meta = {}
		vendor_countries = {}
		vendor_id = nil
		
		if(!@seller_brand.global_brand_id.nil? && @seller_brand.global_brand_id > 0)
			gen_brand = GenBrand.where(id: @seller_brand.global_brand_id).first
			if(gen_brand.present?)
				data[:brand_name] = gen_brand.name
				vendor_id = gen_brand.vendor_id
			end
		end
		
		data[:brand_name] = @seller_brand.name if(data[:brand_name].blank?)
		vendor_id = @seller_brand.vendor_id if(vendor_id.nil?)
		
		if(!vendor_id.nil?)
			SellerBrand.vendor_info(Vendor.where(id: vendor_id).first, vendor_countries, data)
			
			if(!vendor_countries.empty?)
				meta[:data_names] = ['countries']
				meta[:countries] = AddrCountry.select('id, updated_at, country_code, name_full_eng, name_full_rus, iso_code_2, iso_code_3').where(country_code: vendor_countries.keys).find_all
			end
		end
		
		render_result(
			data: data,
			meta: meta
		)
	end
	
	
	# DELETE /:id/
	# -----------
	# Delete a brand.
	#
	# RETURN VALUES:
	# data: empty
	# meta:
	#  success: whether the operation suceeded
	#  deleted: total number of brands deleted
	#
	def destroy
		res_meta = {success: false}
		time_start = Time.now
		
		
		render_result(data: nil, meta: res_meta)
	end
	
	
	def scopes_required
		pparams = params.permit(:method, :req_action)
		render_result(data: {scopes: general_scopes_list(current_user, PROJECT_RESTRICTED_AREA_ECOMMERCE_SELLERS, pparams[:req_action], pparams[:method])})
	end
	
	### ========================================================= PRIVATE ================================================================
	### ==================================================================================================================================
	private

	
	def authenticate_and_authorize_user_action
		authenticate_user! # Devise authentication. It must be called after protect_from_forgery to CSRF-token work properly.
		pparams = params.permit(:seller_id)
		
		roles = nil
		if(action_name == 'update_brands')
			roles = [:objorg_seller]
		end
		
		return if(!authorize_seller_access(pparams[:seller_id], roles))
		
		authorize SellerBrand # Pundit authorization.
	end
	
	
	def authenticate_and_authorize_user_action_and_object
		pparams = params.permit(:seller_id, :id)

		return if(!authorize_seller_access(pparams[:seller_id]))
		
		if(pparams[:id].present? && pparams[:id].numeric?)

			@seller_brand = SellerBrand.where(id: pparams[:id].to_i, seller_id: @seller_id).first			
			if(@seller_brand.blank?)
				render :nothing => true, :status => :not_found and return
			end
		end

		authorize @seller_brand # Pundit authorization.
	end
end