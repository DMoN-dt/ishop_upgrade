module DT_JsonAPI
	def create_response (opts)
		return nil if(opts.nil?)
		# opts: Data, errors, meta, jsonapi, links {self, related, pagination}, included
		#
		# Primary Data MUST be either:
		# - a single resource object, a single resource identifier object, or null, for requests that target single resources
		# - an array of resource objects, an array of resource identifier objects, or an empty array ([]), for requests that target resource collections
		#
		# HTTP Error Code:
		# For instance, 400 Bad Request might be appropriate for multiple 4xx errors or 500 Internal Server Error might be appropriate for multiple 5xx errors.
		#
		# Errors: id, status, code, title, detail, meta
		# status - the HTTP status code applicable to this problem, expressed as a string value.
		# code   - an application-specific error code, expressed as a string value.
		# title  - a short, human-readable summary of the problem that SHOULD NOT change from occurrence to occurrence of the problem, except for purposes of localization.
		# detail - a human-readable explanation specific to this occurrence of the problem. Like title, this field’s value can be localized.
		
		opts.delete(:data) if(!opts[:data].nil? && opts[:errors].present?) # The members Data and Errors MUST NOT coexist in the same document.
		opts.delete(:included) if(opts.include?(:included) && opts[:data].nil?) # If a document does not contain a top-level Data key, the Included member MUST NOT be present either.
		
		# My Optional: data_errors: [{errcode: ...., errtext: ....}] - if data exists but with some errors
		
		return opts
	end
	
	
	def render_result (*opts)
		render json: create_response(opts[0]), status: ((opts[0][:status].blank?) ? :ok : opts[0][:status])
	end
	
	
	def render_error (err_opts, http_status = nil)
		render json: create_response({
				errors: [
					{detail: err_opts}
				]
		}), status: ((http_status.blank?) ? 500 : http_status)
	end
	
end