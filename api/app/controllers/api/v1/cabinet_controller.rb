class Api::V1::CabinetController < Api::ApiSecuredController
	before_action -> {@without_devise = true}
	before_action -> {authorize_request! false, true, :user } #, :only => [:scopes_required]
	
	before_action :authorize_user_action
	after_action  :verify_authorized

	
	def cabinet_general_info
		
		data = {
			mode: (MARKETPLACE_SHOP ? 'estore' : (MARKETPLACE_RETAIL ? 'retail' : (MARKETPLACE_FULL ? 'full' : 'unknown'))),
			user: {
				name: current_user.name,
				# nickname: current_user.nickname,
				
				terms_of_use_accepted: current_user.terms_of_use_accepted?,
				is_allowed: current_user.is_allowed_to_profile?,
				
				tzone: $user_tzone,
				tzone_name: $user_tzone_name,
				preferred_lang: $user_preferred_lang,
				
				current_customer_id: Customer.pub_safe_uid(nil, current_user.current_customer_id, true),
				is_seller: current_user.is_user_allowed_to_own_ecommerce?,
				is_allowed_ecommerce: current_user.is_allowed_to_ecommerce?,
			}
		}
		
		if(MARKETPLACE_RETAIL or MARKETPLACE_FULL)
			data[:user][:current_seller_id] = current_user.current_seller_id
		end
		
		render_result(data: data)
	end
	
	
	### ========================================================= PRIVATE ================================================================
	### ==================================================================================================================================
	private

	
	def authorize_user_action
		authorize Cabinet # Pundit authorization.
	end
	
end