require 'net/http'
require 'uri'
require PROJECT_HOME_PATH_GENERAL + 'modules/json_api'
require PROJECT_HOME_PATH_GENERAL + 'modules/auth_token'
require PROJECT_HOME_PATH_GENERAL + 'modules/own_token_jwt'


AUTH_REASON_LOGIN               = 'login'
AUTH_REASON_ELEVATE_PRIVELEGES  = 'j.elvt'
AUTH_REASON_FETCH_USER_TOKEN    = 'j.utkn'
AUTH_REASON_REFRESH_TOKEN       = 'j.rftn'


class AuthController < ApplicationController
	include DT_AuthToken
	include DT_JsonAPI
	
	def login
		try_login
	end
	
	
	def login_check # response is JSON
		try_login(false, false)
	end
	
	
	def login_to_auth # response is JSON
		uri = URI(request.referrer)
		render_result(
			data: {redirect_to: redirect_to_auth(AUTH_REASON_LOGIN, 'user', request.format, uri.request_uri, false, true)
		})
	end
	
	
	def elevate_priveleges # response is JSON
		pparams = params.permit(:req_scopes)
		
		uri = URI(request.referrer)

		if(user_signed_in?)
			(render(json: nil, status: :bad_request) and return) if(pparams[:req_scopes].blank?)
			authorize_token_uri(AUTH_REASON_ELEVATE_PRIVELEGES, pparams[:req_scopes], uri.request_uri)
		else
			redirect_to_auth(AUTH_REASON_LOGIN, 'user', request.format, uri.request_uri)
		end
	end

	
	def fetch_token # response is JSON
		if(user_signed_in?)
			authorize_token_uri(AUTH_REASON_FETCH_USER_TOKEN)
		else
			render json: nil, status: :unauthorized
		end
	end
	
	
	# def refresh_token # response is JSON
	# 	pparams = params.permit(:refresh_token, :refresh_hash)
	# 	
	# 	if(user_signed_in? && pparams[:refresh_token].present?)
	# 		authorize_token_uri(AUTH_REASON_REFRESH_TOKEN)
	# 		
	# 		# Request access token from authorization service
	# 		response = fetch_url(SERVICE_AUTH_URL_GET_TOKEN, :post, {
	# 			client_id: JWT_OAUTH_TOKEN_APPCLIENT_ID,
	# 			client_secret: JWT_OAUTH_TOKEN_APPCLIENT_SECRET,
	# 			redirect_uri: ((Rails.env.production? || Rails.env.staging?) ? 'https://' : 'http://') + THIS_SITE_DOMAIN + auth_callback_path,
	# 			grant_type: 'refresh_token',
	# 			refresh_token: pparams[:refresh_token]
	# 		})
	# 		
	# 		if(response[:status] == 200)
	# 		
	# 		end
	# 		
	# 	else
	# 		render json: nil, status: :unauthorized
	# 	end
	# end
	

	# LogOut from this service on current browser
	#
	def logout # response is HTML / JSON
		if(request.format.json?)
			sign_out current_user if(user_signed_in?)
			render_result(data: {status: 'ok'})
		
		else
			if(user_signed_in?)
				sign_out current_user
				flash.notice = I18n.t('devise.sessions.signed_out')
			else
				flash.notice = I18n.t('devise.sessions.already_signed_out')
			end
			redirect_to root_path
		end
	end
	
	
	# LogOut from this service on all browsers
	#
	def logout_all
		if(!user_signed_in?)
			flash.notice = I18n.t('devise.sessions.already_signed_out')
			redirect_to root_path and return
		end
		
		sign_out current_user
		flash.notice = I18n.t('devise.sessions.signed_out')
		redirect_to root_path # also find sessions/tokens from all browsers
	end
	
	
	# LogOut from authentication service (i.e. from all services) on all browsers
	#
	def logout_auth_all
		sign_out current_user if(user_signed_in?)
		redirect_to SERVICE_AUTH_URL_SIGN_OUT
	end
	
	
	# OAuth2 Authorization Callback
	#
	def callback
		pparams = params.permit(:code, :state)
		response_format = nil
		auth_token = nil
		scopes_received = nil
		state = nil

		if(pparams[:state].present?)
			pparams[:state] = pparams[:state][0,JWT_OWN_NEEDS_OAUTH_TOKEN_MAX_LENGTH]
			
			state = DT_TokenJWT::OwnNeeds.verify(pparams[:state], {time_limit: 1.minute})
			if(state[:status] == :request_timeout) && (state[:repeatable])
				if(DT_TokenJWT::OwnNeeds.token_sub(state[:token]) == AUTH_REASON_LOGIN)
					try_login(true) and return
				else
					head(state[:status]) and return
				end
			elsif(state[:status] != :ok)
				head(state[:status]) and return
			end
		
			if(pparams[:code].present?)
				request_reason = DT_TokenJWT::OwnNeeds.token_sub(state[:token])
				if((request_reason == AUTH_REASON_LOGIN) && user_signed_in?)
					flash.notice = I18n.t('devise.failure.already_authenticated')
					redirect_to root_path and return
				end
				
				# Request access token from authorization service
				response = fetch_url(SERVICE_AUTH_URL_GET_TOKEN, :post, {
					client_id: JWT_OAUTH_TOKEN_APPCLIENT_ID,
					client_secret: JWT_OAUTH_TOKEN_APPCLIENT_SECRET,
					redirect_uri: ((Rails.env.production? || Rails.env.staging?) ? 'https://' : 'http://') + THIS_SITE_DOMAIN + auth_callback_path,
					grant_type: 'authorization_code',
					code: pparams[:code]
				})

				if(response[:status] == 200)
					if(response[:body] && response[:body]['access_token'].present?) 
						
						# Verify Access Token received
						ret = verify_token_for_access(
							JSON.parse(response[:body])['access_token'], false, false, 
							(DT_TokenJWT::OwnNeeds.token_sub(state[:token]) == AUTH_REASON_LOGIN) ? {any: [:user]} : {any: []}
						)
						logger.warn ret.to_json
						if(ret[:status] == :ok)
							
							# Verify Issue date and tme with leeway
							if((auth_token_time_now - ret[:auth_token][0]['iat']) <= 2.minutes)

								# Compare token's stored hash of state and hash of pparams[:state]
								if(ret[:auth_token][0]['stt'] == XXhash.xxh32(pparams[:state], 0x74B520D6).to_s(16))

									response_format = state[:token][0]['cbfmt'] if(state[:token][0]['cbfmt'].present?)
									
									# Compare scopes received and requested by client
									scopes_requested = state[:token][0]['scp'].split(' ').map(&:to_sym)
									scopes_received = ret[:auth_token][0]['scp'].split(' ').map(&:to_sym)
									
									if((scopes_received - scopes_requested).empty?)
										auth_token = ret[:auth_token]
										
										if(state[:token][0]['usrid'].present?)
											if(!user_signed_in?)
												response[:status] = :bad_request
											elsif(current_user[MAIN_SITE_AUTH_USER_ID_COLUMN].is_a?(Integer))
												response[:status] = :bad_request if(current_user[MAIN_SITE_AUTH_USER_ID_COLUMN] != state[:token][0]['usrid'].to_i)
											else
												response[:status] = :bad_request if(current_user[MAIN_SITE_AUTH_USER_ID_COLUMN].to_s != state[:token][0]['usrid'].to_s)
											end
										end

										if(response[:status] == 200)
											
											if(request_reason == AUTH_REASON_LOGIN)
												response[:status] = auth_token_user_sign_in(ret[:auth_token])
												# if(response[:status] == :ok)
												# 	# Store the Encoded Token to Redis temp table
												# 	auth_token_store_for_user_device(ret[:auth_token], response[:body]['access_token'], current_user.id, $visitor.ip_address, (($visitor.browser_portable?) ? '1' : '0') + $visitor.browser_hash.to_s)
												# end
	
											
											elsif(request_reason == AUTH_REASON_ELEVATE_PRIVELEGES)
													if(response_format == 'json')
														render_result(data: access_token_jwt_export_data(response[:body], auth_token, scopes_received))
													else
														redirect_to root_path
													end
												return
											
											elsif(request_reason == AUTH_REASON_FETCH_USER_TOKEN)
												response[:status] = ((response_format == 'json') ? :ok : :not_acceptable)
	
											else
												response[:status] = :not_acceptable
											end
											
										end
										
									else
										response[:status] = :not_acceptable
									end
								else
									response[:status] = :bad_request
								end
							else
								response[:status] = :request_timeout
							end
						else
							response[:status] = ret[:status]
						end
					else
						response[:status] = :unauthorized
						response[:error_desc] = I18n.t('dt_errors.general.access_token_not_received')
					end
				end

				if(response[:status] == :ok)
					if(response_format == 'json')
						if(!performed?)
							render_result(data: access_token_jwt_export_data(response[:body], auth_token, scopes_received))
						end
					else
						flash.notice = I18n.t('devise.sessions.signed_in')
						redirect_to root_path if(!performed?) # redirect to initial previous page
					end
					
				else
					error_msg = response[:error]
					error_msg += ('. ' + response[:error_desc]) if(response[:error_desc].present?)
					error_msg += ('. ' + I18n.t('dt_errors.general.server_said', text: response[:error_server_desc])) if(response[:error_server_desc].present?)
					
					if(response_format == 'json') or (!state.nil? && (st_reason = DT_TokenJWT::OwnNeeds.token_sub(state[:token])).present? && (st_reason[0,2] == 'j.'))
						render_error({detail: error_msg}, response[:status]) if(!performed?)
					else
						flash.alert = error_msg
						redirect_to controller: 'welcome', action: 'error_access_denied' if(!performed?)
					end
				end
				
				return
			end
		end
		
		head(:bad_request)
	end
	
	
	### ========================================================= PRIVATE ================================================================
	### ==================================================================================================================================
	private
	
	def fetch_url (url, method = :get, arguments = nil, redirects_limit = 1, type_want = :json, raise_errors = false)
		failed = false
		err_server_msg = nil
		err_desc = nil
		ret = {}
		host_addr = 'URL'
		
		if(redirects_limit > 0)
			if(url =~ /\A(((https?):)?\/\/)?.+\z/)
				if(url[0,5] == 'http:')
					if(Rails.env.production? || Rails.env.staging?)
						url = 'https' + url[4, url.length - 4]
					end
				elsif(url[0,6] != 'https:')
					if(url[0,2] == '//')
						url = ((Rails.env.production? || Rails.env.staging?) ? 'https:' : 'http:') + url
					else
						url = 'https://' + url
					end
				end
		
				uri = URI(url)
		
				begin
					host_addr = uri.host + ':' + uri.port.to_s
					
					Net::HTTP.start(uri.host, uri.port, :use_ssl => (uri.scheme == 'https')) do |http|
						# http.verify_mode = OpenSSL::SSL::VERIFY_NONE
						# With PEM certificate:
						#http.cert = OpenSSL::X509::Certificate.new(pem)
						#http.key = OpenSSL::PKey::RSA.new(pem)
						#http.verify_mode = OpenSSL::SSL::VERIFY_PEER
						
						begin
							if(method == :post)
								request = Net::HTTP::Post.new(uri.request_uri)
								request.set_form_data(arguments) if(arguments.present? && request)
							else
								request = Net::HTTP::Get.new(uri.request_uri)
							end
						
						rescue NoMethodError => e
							err_desc = I18n.t('dt_errors.tcp.bad_url')
						end
						
						if(request)
							response = http.request(request) # Net::HTTPResponse object
							
							case response
							  when Net::HTTPSuccess
								ret[:status] = response.code.to_i
								
								if((type_want == :html) && !response.content_type.include?('text/html')) or ((type_want == :json) && !response.content_type.include?('/json'))
								  ret[:status] = 415
								end
								
								response.read_body
								ret[:body] = response.body
								
								# response.value Raises an HTTP error if the response is not 2xx (success).
								
								# response headers: response.to_hash
								# Use nokogiri, hpricot, etc to parse response.body

							  when Net::HTTPRedirection
								location = response['location']
								logger.warn "redirected to #{location}"
								
								fetch_url(location, :get, nil, redirects_limit - 1)
							  
							  when Net::HTTPResponse #Net::HTTPBadRequest, Net::HTTPUnauthorized, Net::HTTPForbidden, Net::HTTPNotFound, Net::HTTPNotAcceptable, Net::HTTPRequestTimeOut
								ret[:status] = response.code.to_i
								err_server_msg = (response.message + '. ') if(response.message.present?)

							  else
								failed = true
							end
							
							if(ret[:status] < 200) or (ret[:status] >= 300)
								err_desc = I18n.t(
									I18n.exists?("dt_errors.tcp.http_status_#{ret[:status]}") ? "http_status_#{ret[:status]}" : 'http_status_code',
									scope: 'dt_errors.tcp', code: ret[:status]
								)
							end
							
						end
					end
				
				rescue SocketError => e
					logger.error(e.message) # logger.error("#{self.name} Timeout for #{path}: #{error}") and return
					failed = true
					
					if(e.message.include? 'getaddrinfo: Name or service not known')
						err_desc = I18n.t('dt_errors.socket_errors.name_or_service_is_unknown')
					end

				rescue Errno::ECONNREFUSED => e
					err_desc = I18n.t('dt_errors.tcp.connection_refused')
				end
				# OpenSSL::SSL::SSLError: SSL_connect returned=1 errno=0 state=error: certificate verify failed
				# Timeout::Error

			else
				err_desc = I18n.t('dt_errors.tcp.not_http_https_pattern')
			end
		
		else
			err_desc = I18n.t('dt_errors.tcp.name_or_service_is_unknown')
		end
		
		if(failed or err_desc)
			ret[:error] = I18n.t('dt_errors.socket_errors.failed_to_open_tcp_connection_to', host: host_addr)
			ret[:error_desc] = err_desc
			ret[:error_server_desc] = err_server_msg
			
			if(raise_errors)
				raise(StandardError, ret[:error] + ' (' + err_server_msg.to_s + err_desc.to_s + ')') 
			end
		end
		
		return ret
	end
	
	
	def redirect_to_auth (reason, scopes, response_format = nil, comeback_url = nil, repeated = false, return_uri = false)
		state_opts = {
			issuer: JWT_OWN_NEEDS_OAUTH_TOKEN_ISSUER,
			reason: reason,
			repeated: repeated,
			data: {
				scp: scopes[0,JWT_OWN_NEEDS_OAUTH_TOKEN_SCOPES_MAX_LENGTH]
			}
		}
		
		state_opts[:data][:cburl] = comeback_url if(comeback_url.present?)
		state_opts[:data][:usrid] = current_user[MAIN_SITE_AUTH_USER_ID_COLUMN] if(user_signed_in?)
		
		if(response_format.present?)
			response_format = response_format.to_s
			state_opts[:data][:cbfmt] = (response_format.include?('/') ? response_format.split('/')[1] : response_format )
		end
		
		state_token = DT_TokenJWT::OwnNeeds.generate(state_opts)
		
		if(state_token.length >= JWT_OWN_NEEDS_OAUTH_TOKEN_MAX_LENGTH)
			logger.error "OWN JWT Token length (#{state_token.length.to_s} encoded chars) exceeds MaxLength of #{JWT_OWN_NEEDS_OAUTH_TOKEN_MAX_LENGTH.to_s} chars !!!"
		end
		# logger.warn Base64.decode64(state_token)[0,90].to_json
		
		uri = SERVICE_AUTH_URL_AUTHORIZE + '?' + {
			client_id: JWT_OAUTH_TOKEN_APPCLIENT_ID,
			redirect_uri: ((Rails.env.production? || Rails.env.staging?) ? 'https://' : 'http://') + THIS_SITE_DOMAIN + auth_callback_path,
			response_type: 'code',
			scope: state_opts[:data][:scp],
			state: state_token
			}.to_query
		
		return uri if(return_uri)
		redirect_to(uri)
	end
	
	
	def try_login (repeated = false, inform_already_signedin = true)
		if(user_signed_in?)
			if(request.format.json?)
				render_result(data: {token: nil, signed_in: true})
			else
				flash.notice = I18n.t('devise.failure.already_authenticated') if(inform_already_signedin)
				redirect_to root_path
			end
			return
		end
		
		redirect_to_auth(AUTH_REASON_LOGIN, 'user', request.format, nil, repeated)
	end
	
	
	def authorize_token_uri (reason, scopes_required = nil, comeback_uri = nil)
		scopes_required = 'user api' if(reason == AUTH_REASON_FETCH_USER_TOKEN)

		render_result(
			data: {redirect_to: redirect_to_auth(
				reason,
				scopes_required[0, JWT_OWN_NEEDS_OAUTH_TOKEN_SCOPES_MAX_LENGTH],
				request.format, comeback_uri, false, true)
			})
	end
end