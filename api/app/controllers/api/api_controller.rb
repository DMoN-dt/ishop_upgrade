class Api::ApiController < ActionController::API
  respond_to :json
  # undefined method `protect_from_forgery' for Api::ApiController:Class
  # protect_from_forgery with: :null_session # Prevent CSRF attacks by raising an exception. For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception # Prevent CSRF attacks by raising an exception. For APIs, you may want to use :null_session instead.
  
  @@actions_no_locales_and_cookies = [:error_RobotTryLogin, :lets_encrypt]
  
  ## RESCUEs
  #rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  #rescue_from ActionController::InvalidAuthenticityToken do |exception|
	#if user_signed_in?
	#	sign_out current_user
	#end
	#flash[:error] = "Время сеанса истекло. Для продолжения, необходимо Войти вновь."
  #	redirect_to new_user_session_path
  #end
  
  ## BEFORE ACTIONs
  before_action :ensure_json_request
  
  # Application Default Locale Management:
  # include DT_Application_Locales # this requires 'common/locales'
  # before_action :set_locale, :except => @@actions_no_locales_and_cookies
 
 
  private
	
	def query_pagination_params (max_limit, allowed_order_fields)
		pparams = params.permit(:limit_num, :start_point, :start_page, :get_total, :order => [])

		pparams[:limit_num] = ((pparams[:limit_num].present? && pparams[:limit_num].numeric?) ? pparams[:limit_num].to_i : nil)
		pparams[:get_total] = (pparams[:get_total].present? && pparams[:get_total] == 'true')
		
		if(pparams[:start_point].present? && pparams[:start_point].numeric?)
			pparams[:start_point] = pparams[:start_point].to_i
			pparams[:start_point] = 0 if(pparams[:start_point] < 0)
			pparams[:start_page] = nil
		else
			pparams[:start_page] = ((pparams[:start_page].present? && pparams[:start_page].numeric?) ? pparams[:start_page].to_i : 1)
			pparams[:start_page] = 1 if(pparams[:start_page] < 1)
			pparams[:start_point] = nil
		end
		pparams[:get_total] = ((pparams[:start_point] === 0) or (pparams[:start_page] == 1)) if(!pparams[:get_total])

		order_str = ''
		
		if(pparams[:order].present? && pparams[:order].is_a?(Array))
			pparams[:order].each do |order_item|
				jj = order_item.split(' ')
				if(allowed_order_fields.include?(jj[0]))
					order_str += ', ' if(!order_str.blank?)
					order_str += jj[0] + (((jj[1] == 'desc') || (jj[1] == 'DESC')) ? ' DESC' : ' ASC')
				end
			end
		end

		max_limit = pparams[:limit_num] if(pparams[:limit_num] && (max_limit > pparams[:limit_num]))
		
		offset_num = ((pparams[:start_point].nil?) ? ((pparams[:start_page] - 1) * max_limit) : pparams[:start_point])

		return {
			order_str: order_str,
			get_total: pparams[:get_total],
			max_limit: max_limit,
			offset_num: offset_num,
		}
	end
	
	def ensure_json_request  
		return if(request.format.json?)
		head :not_acceptable #render :nothing => true, :status => 406
	end
	
	
	def marketplace_is_shop?
		return (!defined?(MARKETPLACE_MODE_ONLINE_SHOP) or MARKETPLACE_MODE_ONLINE_SHOP)
	end
	
	
	def marketplace_is_full?
		return (defined?(MARKETPLACE_MODE_ONLINE_SHOP) && (MARKETPLACE_MODE_ONLINE_SHOP != true))
	end
	
	
	def marketplace_is_full_retail?
		return (marketplace_is_full? && defined?(MARKETPLACE_MODE_RETAIL) && (MARKETPLACE_MODE_RETAIL == true))
	end
	
	
	def marketplace_is_full_place?
		return (marketplace_is_full? && (!defined?(MARKETPLACE_MODE_RETAIL) or (MARKETPLACE_MODE_RETAIL != true)))
	end

end