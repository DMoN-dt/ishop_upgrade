class CabinetPolicy < ApplicationPolicy
	
	def cabinet_general_info?
		user.is_allowed_to_profile?
	end
	
	
	# if(defined?(MARKETPLACE_MODE_ONLINE_SHOP) && (MARKETPLACE_MODE_ONLINE_SHOP != true))
    # 
	# end

end