class DT_Visitor
	attr_accessor :browser, :current_user, :add_locale_to_urls, :location, :this_is_sub_service
	attr_reader   :browser_version, :browser_hash, :ip_address


	def initialize (ip_address = nil, is_signed_user = false, user = nil)
		@ip_address = ip_address
		@is_signed_user = is_signed_user
		@current_user = user
	end
	
	
	def browser_hash_calculate
	    # Truncated here......
	end
	
	
	def browser_version
		@browser.version
	end
	
	
	def browser_portable?
		(browser.device.mobile? or browser.device.tablet?)
	end
	

	def browser_cookie_hash_set (cookies, subdomains = true)
		# API is unable to read/write cookies.
	end
	
	
	def browser_cookie_hash (cookies = nil)
		# API is unable to read/write cookies.
		nil
	end
	
	
	def cookie_privacy_agreed=(is_agreed)
		@cookie_privacy_agreed = is_agreed
	end
	
	
	def cookie_privacy_agreed?
		@cookie_privacy_agreed === true
	end
	

	def location_city
		((@location.present? && @location[:city].present?) ? @location[:city] : nil)
	end
	
	
	def signed_in=(is_signed_in)
		@is_signed_user = is_signed_in
		@current_user = nil if(!is_signed_in)
	end
	
	
	def signed_in?
		@is_signed_user === true
	end
	
	
	### CLASS Methods
	
	def self.generate_rnd_chars(num, extra = false)
		if(extra)
			o = [('a'..'z'), ('A'..'Z'), (0..9), ['!','@','#','$','%','^','&','*','(',')','_','-','=','+','|','\\','/','>','<','.',':','~','[',']','{','}']].map { |i| i.to_a }.flatten
		else
			o = [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten
		end
		
		return ((0...num).map { o[rand(o.length)] }.join)
	end

	
	### ========================================================== PRIVATE ==========================================================
	### =============================================================================================================================
  
	private
	
end