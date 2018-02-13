Rails.application.routes.draw do
	# The priority is based upon order of creation: first created -> highest priority. See how all your routes lay out with "rake routes".
	
	## USERS LOGON
	devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout' }, :controllers => { sessions: "user/sessions", passwords: "user/passwords", registrations: "user/registrations" } #, skip: [:registrations]#, :controllers => { omniauth_callbacks: 'omniauth_callbacks' } #, :controllers => { sessions: "users/track_sessions" }
	
	use_doorkeeper
	# Doorkeeper will mount following routes:
	# GET       /oauth/authorize/:code
	# GET       /oauth/authorize
	# POST      /oauth/authorize
	# DELETE    /oauth/authorize
	# POST      /oauth/token
	# POST      /oauth/revoke
	# resources /oauth/applications
	# GET       /oauth/authorized_applications
	# DELETE    /oauth/authorized_applications/:id
	# GET       /oauth/token/info
	
	root 'doorkeeper/applications#index' # any root_path is need for Doorkeeper Views
	
	get  '/logout_all' => 'welcome#logout_all'
	
	get  '/pending/wait_confirm' => 'welcome#wait_confirm'
	
	## ERRORs
	get   'error/denied' => 'welcome#error_access_denied'
	
	## SPAM-VIRUS ROBOTS
	extend SpamBotsRoutes
end
