require File.expand_path('../../../../.general/config/initializers/site_settings', __dir__)

if(Rails.env.production? || Rails.env.staging?)
	ENABLE_RECAPTCHA = true
else
	ENABLE_RECAPTCHA = false
end

THIS_SITE_DOMAIN = 'api.' + PROJECT_SITE_URL_HOST # Main domain name of this service (not entire project)

MAIN_SITE_AUTH_USER_ID_COLUMN = 'id' # auth_db.users.id <-> site_db.users.column - Should be smth like 'auth_user_id'