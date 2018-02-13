# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.unregister :json
Mime::Type.register 'application/json', :json, [
	'text/x-json', 'application/jsonrequest', # defaults
	'application/vnd.api+json', # JSON API 'standard'
	'application/vnd.api.DT_Zagruz.v1+json', 'application/vnd.api.DT_Zagruz+json' # Vendor's custom type
]