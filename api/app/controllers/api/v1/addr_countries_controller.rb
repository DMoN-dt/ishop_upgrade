class Api::V1::AddrCountriesController < Api::ApiSecuredController
	before_action -> {authorize_request! false, true, :user }, :only => [:scopes_required, :index]
	before_action -> {authorize_request! false, true, {any: [:adm_gen_read]} },  :only => [:show]
	before_action -> {authorize_request! true,  true, {any: [:adm_gen_write]} }, :only => [:create, :update, :destroy]
	
	before_action :authenticate_and_authorize_user_action,             :except => [:scopes_required, :destroy]
	before_action :authenticate_and_authorize_user_action_and_object,  :only   => [:show, :destroy]
	after_action  :verify_authorized, :except => [:scopes_required]
	
	def index
		qparams = query_pagination_params(100, ['updated_at', 'name_full_rus', 'iso_code_2', 'iso_code_3', 'name_full_eng', 'country_code'])

		data = {}
		meta = {}

		meta[:data_total_cnt] = AddrCountry.count if(qparams[:get_total])
		data = AddrCountry.order(qparams[:order_str]).limit(qparams[:max_limit]).offset(qparams[:offset_num])

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
	# Show a country.
	#
	# RETURN VALUES:
	# data: All country's fields
	#
	def show
		render_result(
			data: @addr_country,
			meta: {}
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
		# render_result(data: {scopes: general_scopes_list(current_user, PROJECT_RESTRICTED_AREA_ECOMMERCE_SELLERS, pparams[:req_action], pparams[:method])})
	end
	
	### ========================================================= PRIVATE ================================================================
	### ==================================================================================================================================
	private

	
	def authenticate_and_authorize_user_action
		authenticate_user! # Devise authentication. It must be called after protect_from_forgery to CSRF-token work properly.
		authorize AddrCountry # Pundit authorization.
	end
	
	
	def authenticate_and_authorize_user_action_and_object
		pparams = params.permit(:id)

		if(pparams[:id].present? && pparams[:id].numeric?)

			@addr_country = AddrCountry.where(id: pparams[:id].to_i).first			
			if(@addr_country.blank?)
				render :nothing => true, :status => :not_found and return
			end
		end

		authorize @addr_country # Pundit authorization.
	end
end