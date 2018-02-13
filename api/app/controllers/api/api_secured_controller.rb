require 'browser'
require PROJECT_HOME_PATH_GENERAL + 'modules/json_api'   if(!defined?(DT_JsonAPI))
require PROJECT_HOME_PATH_GENERAL + 'modules/visitor'    if(!defined?(DT_Visitor))
require PROJECT_HOME_PATH_GENERAL + 'modules/auth_token' if(!defined?(DT_AuthToken))
require PROJECT_HOME_PATH_GENERAL + 'modules/market/marketplace'


class Api::ApiSecuredController < Api::ApiDeviseSecuredController
	include Pundit  #include PunditNamespaces
	
	include DT_AuthToken
	include DT_JsonAPI

	before_action :fill_visitor_info
	
	# Authorization and Authentication Filters Chain for Controllers:
	# ---------------------------------------------------------------
	# before_action -> {authorize_request! true, true, {all: [:gread], any: [:seller, :ecom]} } # arguments: ValidateOnAuthService, AllowVisitorChanges, ScopesRequired.
	# before_action :authenticate_and_authorize_user_action, :only => [:index]
	# before_action :authenticate_and_authorize_user_action_and_object, :except => [:index]
	# after_action  :verify_authorized
	
	
	### ========================================================= PRIVATE ================================================================
	### ==================================================================================================================================
	private
	
	
	def fill_visitor_info
		$visitor = DT_Visitor.new(request.remote_ip)
		$visitor.browser = ::Browser.new(request.env['HTTP_USER_AGENT'])
		$visitor.browser_hash_calculate
		$visitor.this_is_sub_service = true
		
		# $visitor.location = location_detect_by_IP if($visitor.location.blank?)
		# @is_sverdlovsk_region = ($visitor.location[:subdivision_code] == 'SVE')
	end
	
	
	def current_user
		if(defined?(user_signed_in?) && $current_user.blank?)
			super
		else
			$current_user
		end
	end

	
	# Find a Seller by ID and verify the User has general access to this seller
	def authorize_seller_access (seller_id, access_roles = nil)
		if(seller_id.present?)
			if(seller_id.is_a?(String))
				if(seller_id == 'null')
					@seller_id = 0
				elsif(seller_id.numeric?)
					@seller_id = @seller_id.to_i
				else
					return false
				end
			elsif(seller_id.is_a?(Integer))
				@seller_id = seller_id
			else
				return false
			end
			
			if(::MARKETPLACE_SHOP && (@seller_id == 0)) or (!::MARKETPLACE_SHOP && (@seller = Seller.where(id: @seller_id).first).present?)
				if(Seller.verified_access?(current_user, @seller_id, @seller, (access_roles || []) + [:gen_some_access]))
					current_user.action_seller_id = @seller_id
					current_user.action_seller = @seller
					return true
				end
			end
		end
		
		render :json => [{:status => 'error', :error => 'Доступ запрещён!', :status_text => 'Доступ запрещён!'}], :status => :forbidden
		return false
	end
end
