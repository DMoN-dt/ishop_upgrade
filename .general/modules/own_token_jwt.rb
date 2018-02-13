module DT_TokenJWT
  module OwnNeeds
    class << self
		def generate(opts = {})
			::JWT.encode(
				token_payload(opts),
				secret_key(opts),
				encryption_method,
				token_headers(opts)
			)
		end
		
		
		def decode (jwt, opts = {})
			begin
				::JWT.decode(jwt, secret_key(opts), true, opts)
			rescue JWT::VerificationError
				nil
			end
		end
		
		
		def verify (jwt, opts = {})
			# Local Decode and Verify of Token
			# erased here....
		end
		
		
		def token_sub (token)
			token[0]['sub'].split('::')[0]
		end
		
		
		private

		def token_payload_sub(opts = {})
			opts[:reason] + '::' + PROJECT_SITE_URL_HOST
		end
		
		def token_payload_time_now
			DateTime.now.new_offset(0).to_i
		end
		
		def token_payload(opts = {})
			{
			  iss: opts[:issuer],
			  iat: token_payload_time_now,
			  sub: token_payload_sub(opts),
			  rpt: (opts[:repeated] ? 1 : 0)
			}.merge!(opts[:data])
		end
		
		def token_headers(opts = {})
			# kid - key ID
			# It is a hint indicating which key was used to secure the JWT.
			# This parameter allows originators to explicitly signal a change of key to recipients.
			# The structure of the kid value is unspecified. Its value MUST be a case-sensitive string.
			{kid: 1}
		end
		
		def encryption_method
			:hs512.to_s.upcase
		end
		
		def secret_key(opts = {})
			# return secret_key_file unless secret_key_file.nil?
			# return rsa_key if rsa_encryption?
			# return ecdsa_key if ecdsa_encryption?
			JWT_OWN_NEEDS_OAUTH_TOKEN_SECRET
		end

		# def secret_key_file
		# 	return nil if DT_TokenJWT::OwnNeeds.configuration.secret_key_path.nil?
		# 	return rsa_key_file if rsa_encryption?
		# 	return ecdsa_key_file if ecdsa_encryption?
		# end

		# def rsa_encryption?
		# 	/RS\d{3}/ =~ encryption_method
		# end
		# 
		# def ecdsa_encryption?
		# 	/ES\d{3}/ =~ encryption_method
		# end
		# 
		# def rsa_key
		# 	OpenSSL::PKey::RSA.new(DT_TokenJWT::OwnNeeds.configuration.secret_key)
		# end
		# 
		# def ecdsa_key
		# 	OpenSSL::PKey::EC.new(DT_TokenJWT::OwnNeeds.configuration.secret_key)
		# end
		# 
		# def rsa_key_file
		# 	secret_key_file_open { |f| OpenSSL::PKey::RSA.new(f) }
		# end
		# 
		# def ecdsa_key_file
		# 	secret_key_file_open { |f| OpenSSL::PKey::EC.new(f) }
		# end
		# 
		# def secret_key_file_open(&block)
		# 	File.open(DT_TokenJWT::OwnNeeds.configuration.secret_key_path, &block)
		# end

	end
  end
end