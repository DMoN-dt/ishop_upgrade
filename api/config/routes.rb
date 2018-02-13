Rails.application.routes.draw do
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	
	# devise_for :users, skip: [:registrations, :sessions, :passwords]
	
	# use_doorkeeper
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
	
	#root 'doorkeeper/applications#index' # any root_path is need for Doorkeeper Views
	
	root 'welcome#index'
	
	## SSL Certificate through Let's Encrypt
	get '/.well-known/acme-challenge/:id' => 'welcome#lets_encrypt'
	
	## API
	extend ApiRoutes
	
	## SPAM-VIRUS ROBOTS
	extend SpamBotsRoutes

end
