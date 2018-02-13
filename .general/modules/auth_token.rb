# JWT Best practices:
# -------------------
# Instead of simply expiring JWTs after a certain time, consider implementing JWTs that support
# N usages - can only be used N times before they expire within expire_period
# All JWT authentication failures should generate an "error" response header that states why the JWT authentication failed. e.g. "expired", "no usages left", "revoked", etc. This helps implementers know why their JWT is failing.
# JWT's should not be logged in log files. The contents of a JWT can be logged, but not the JWT itself.
# Use RSA assymetric keys to verify token's signature before asking auth-server to verify the token.
# Use a cron job to generate an app secret every few hours or so (however long your access tokens are valid for) and save it to DB with a token.


module Doorkeeper
  module JWT
    class << self
		def decode_generated_token (jwt, opts = {})
			opts = { application: {} }.merge(opts)
			::JWT.decode(jwt, secret_key(opts), true, opts)
		end
	end
  end
end


module DT_AuthToken

	### ========================================================= PRIVATE ================================================================
	### ==================================================================================================================================
	private
	
	def authorize_request!(validate_on_auth_service, allow_visitor_changes, *scopes_required)
		ret = verify_token_for_access(authorization_token, validate_on_auth_service, allow_visitor_changes, *scopes_required)
		if(ret[:status] == :ok)
			ret[:status] = auth_token_user_sign_in(ret[:auth_token], (!defined?(@without_devise) or !@without_devise))
		end
		
		if(ret[:status] != :ok) && !performed?
			ret[:status] = Rack::Utils::SYMBOL_TO_STATUS_CODE[ret[:status]] if(ret[:status].is_a?(Symbol))
			
			if(request.format.json? or !defined?(respond_to))
				render json: nil, status: ret[:status]
			else
				error_text = (
					I18n.exists?("dt_errors.tcp.http_status_#{ret[:status]}") ? I18n.t("dt_errors.tcp.http_status_#{ret[:status]}") : I18n.t("dt_errors.tcp.http_status_code", code: ret[:status])
				)
				flash.alert = error_text
				redirect_to error_denied_path # controller: 'welcome', action: 'error_access_denied' if(!performed?)
			end
		end
	end
	

	def verify_token_for_access (request_token, validate_on_auth_service, allow_visitor_changes, *scopes_required)
		return {status: :unauthorized} if(request_token.blank? or (request_token == 'null'))
		
		required_scopes_is_hash = ((scopes_required.length == 1) && scopes_required[0].is_a?(Hash))
		token_scopes = nil
		
		# Local Decode and Verify of Token
		begin
			auth_token = Doorkeeper::JWT.decode_generated_token(request_token, {
				algorithms: [Doorkeeper::JWT.configuration.encryption_method.to_s],
				verify_iss: true, iss: JWT_OAUTH_TOKEN_ISSUER,
				verify_iat: true, iat_leeway: 5.minutes,
				verify_expiration: true, verify_not_before: true
			})
		rescue JWT::DecodeError => e
			return {status: ((e.message == 'Nil JSON web token') ? :unauthorized : :bad_request)}
		end

		# Verify the token is for me
		if(auth_token[0]['sub'] != (JWT_OAUTH_TOKEN_APPCLIENT_NAME + '::' + PROJECT_SITE_URL_HOST))
		    # Truncated.....
		end

		# Verify required scopes throuh the Query of Authorization service
		if(validate_on_auth_service) # 
			if(required_scopes_is_hash)
				
				if(scopes_required[0][:any].present?)
					return {status: :unauthorized} if(!doorkeeper_authorize_token!(false, *scopes_required[0][:any]))
				end
				
				if(scopes_required[0][:all].present?)
					scopes_required[0][:all].each do |rscope|
						return {status: :unauthorized} if(!doorkeeper_authorize_token!(false, *rscope))
					end
				end

			else
				return {status: :unauthorized} if(!doorkeeper_authorize_token!(false, scopes_required))
			end
			
			return {status: :unauthorized} if(performed?)
			
		else
			# Verify required scopes locally
			token_scopes = auth_token[0]['scp'].split(' ').map(&:to_sym) if(token_scopes.nil?)

			if(required_scopes_is_hash)
				return {status: :forbidden} if not ((scopes_required[0][:any].blank? or scopes_required[0][:any].any?{|scp| token_scopes.include?(scp)}) &&
													(scopes_required[0][:all].blank? or (scopes_required[0][:all] - token_scopes).empty?))
			else
				return {status: :forbidden} if not (scopes_required.any?{|scp| token_scopes.include?(scp)})
			end
		end

		# Verify that Usage counter not exceed the max of token and max of local settings
		# store to local Redis DB: 1) xxhash(request_token), 2) last 10 chars of request_token, 3) usage counter

		
		# Validate Visitor's Environment (device, platform, browser, ip address)
		token_scopes = auth_token[0]['scp'].split(' ').map(&:to_sym) if(token_scopes.nil?)
		
		if(required_scopes_is_hash)
			scopes_validate = ((scopes_required[0][:any] || []) & token_scopes) + (scopes_required[0][:all] || [])
		else
			scopes_validate = scopes_required & token_scopes
		end

		return validate_authorize_token(auth_token, allow_visitor_changes, scopes_validate) # Validate IP, Browser and Environment changes
	end
	
	
	def auth_token_time_now
		DateTime.now.new_offset(0).to_i
	end
	
	
	def auth_token_scopes_lifetime (scopes_validate, lifetime)
		scopes_validate.each do |rscope|
		    # Truncated............
		end
		return lifetime
	end
	
	
	def auth_token_expiration_time (auth_token, scopes_validate, expires_in)
		expires_at = auth_token_scopes_lifetime(scopes_validate, ((expires_in.present? && (expires_in.is_a?(Integer) or expires_in.numeric?)) ? expires_in.to_i : 4.hours)) + auth_token[0]['iat'].to_i
		token_exp  = auth_token[0]['exp'].to_i
		return ((expires_at <= token_exp) ? expires_at : token_exp)
	end
	
	
	def auth_token_expired? (auth_token, scopes_validate, expires_in)
		return true if(auth_token_time_now >= auth_token_expiration_time(auth_token, scopes_validate, expires_in))
		# Check auth_token[0]['max']: limit counter usage
	end
	
	
	def auth_token_user_sign_in (auth_token, make_sign_in = true)
		if(auth_token[0]['usr'].present?)
			user = User.where(MAIN_SITE_AUTH_USER_ID_COLUMN.to_s => auth_token[0]['usr']['id']).first
			if(user.present?)
				email_verified = nil
				email_hash_verified = nil

				if(auth_token[0]['usr']['emlhs'].present? && defined?(user.email_hash_for_token))
					email_hash_verified = (auth_token[0]['usr']['emlhs'] == user.email_hash_for_token)
				end
				
				if(email_hash_verified.nil? or email_hash_verified) && (auth_token[0]['usr']['email'].present? && user[:email].present?)
					email_verified = (auth_token[0]['usr']['email'] == user[:email])
				end
				
				email_verified = true if(email_verified.nil? && email_hash_verified)
				
				# if(!email_verified)
				#  Ask Auth Service of new user's email or email-hash. If they are changed then update local storage and verify them again.
				# end
				
				if(email_verified)
					
					if(make_sign_in)
						sign_in user
						return :ok if(user_signed_in?)
					else
						if(user.credentials_present?)
							$current_user = user
							return :ok
						end
					end
				end
			end
		end

		return :unauthorized
	end
	
	
	# Store the Request Encoded Token to Redis temp table on user's login
	#
	# def auth_token_store_for_user_device (auth_token, encoded_token, user_id, ip_addr, bw_hash)
	# 	# For UserID, IP, Browser Hash
	# 
	# end

	
	def validate_authorize_token (auth_token, allow_visitor_changes = true, *scopes_required)
		return {status: :bad_request} if(auth_token.blank? or auth_token[0]['vis'].blank?)
		
		$visitor = DT_Visitor.new(request.remote_ip) if($visitor.nil?)
		$visitor.browser = Browser.new(request.env['HTTP_USER_AGENT'])
		
		vis_mobi = (($visitor.browser_portable?) ? 1 : 0)
		vis_bver = $visitor.browser_version.to_i
		token_vis_bver = auth_token[0]['vis']['bver'].to_i

		# Truncated......

		return {status: :ok, auth_token: auth_token}
	end
	
	
	def authorization_token
		Doorkeeper::OAuth::Token.from_request(request, *Doorkeeper.configuration.access_token_methods)
	end
	
	
	def doorkeeper_authorize_token!(raise_error, *scopes)
		@_doorkeeper_scopes = scopes.presence || Doorkeeper.configuration.default_scopes
		raise_error ? doorkeeper_authorize!(*scopes) : valid_doorkeeper_token?
	end
		
	
	def access_token_jwt_export_data (jwt_body, auth_token, scopes_received)
		jwt_body = JSON.parse(jwt_body) if(!jwt_body.is_a?(Hash))
		
		{
		token: jwt_body['access_token'],
		scope: jwt_body['scope'],
		expires_at: auth_token_expiration_time(auth_token, scopes_received, jwt_body['expires_in']),
		time_now:   auth_token_time_now
		}
	end
	
	
	def general_scopes_list (user, area_type, token_action_name, token_action_method)
		
		common = {
			index:   'gread',
			show:    'gread',
			create:  'gwrite',
			update:  'gwrite',
			destroy: 'gwrite',
		}
		
		common_with_methods = {
			index_get:    'gread',
			index_post:   'gwrite',
			index_put:    'gwrite',
			index_delete: 'gwrite',
		}

		scopes_add = []
		
		if(area_type == PROJECT_RESTRICTED_AREA_GENERAL)
		    # Truncated...........
		end
		
		
		if(token_action_name.present? && token_action_method.present?)
			n = (token_action_name.to_s + '_' + token_action_method.to_s).to_sym
			scopes = ((common_with_methods[n].nil?) ? common[token_action_name.to_sym].to_s : common_with_methods[n].to_s)
		else
			scopes = ((token_action_name.present?) ? common[token_action_name.to_sym].to_s : common)
		end

		if(!scopes_add.empty?)
			scopes_add = ((scopes.present?) ? ' ' : '') + scopes_add.join(' ')
			scopes.is_a?(Hash) ? scopes.each{|k,v| scopes[k] = v + scopes_add} : (scopes += scopes_add)
		end
		
		return scopes
	end
end