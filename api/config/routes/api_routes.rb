require 'api_version'

module ApiRoutes
  def self.extended(router)
    router.instance_exec do
		
		# Namespace the controllers without affecting the URI
		# scope module: :v2, constraints: ApiVersion.new('v2') do
		# end
		# - OR -
		# scope module: :v1, constraints: ApiVersion.new('v1', true) do
		# 	post 'auth/login', to: 'authentication#authenticate'
		# 	post 'signup', to: 'users#create'
		# end

		namespace :api do
			namespace :v1, constraints: ApiVersion.new('v1', true) do

				post 'cabinfo' => 'cabinet#cabinet_general_info'
				
				# Countries/:COUNTRY_ID/
				resources :addr_countries, path: 'countries', as: 'countries', :constraints => {:id => /(I|0C)[0-9]+/}, only: [:index, :create, :update, :destroy] do
					collection {post 'token_scopes', action: 'scopes_required'}
					member     {post 'token_scopes', action: 'scopes_required'}
				end
				
				
				# Measure_units/:MEASURE_UNIT_ID/
				resources :gen_measurement_units, path: 'measure_units', as: 'measure_units', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :update, :destroy] do
					collection {post 'token_scopes', action: 'scopes_required'}
					member     {post 'token_scopes', action: 'scopes_required'}
				end
				
				
				# Sellers/:SELLER_ID/
				resources :sellers, :constraints => {:id => /(\d+(-)\d+(:|\.)\d+(-)(\d+|[0-9a-fA-F]{8}))|null|0/}, only: [:index, :create, :update, :destroy] do
					collection {post 'token_scopes', action: 'scopes_required'}
					member     {post 'token_scopes', action: 'scopes_required'}
					
					
					# Sellers/:SELLER_ID/ProdGroups/:PROD_GROUP_ID/
					resources :seller_products_groups, path: 'prodgroups', as: 'prodgroups', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :update, :destroy] do
						collection do
							post 'token_scopes', action: 'scopes_required'
							
							post 'update',  action: 'update_groups'
						end
						
						member do
							post 'token_scopes', action: 'scopes_required'
							
							post 'parents', action: 'group_parents'
							post 'parents_tree', action: 'group_parents_tree'
						end
						
						
						# Sellers/:SELLER_ID/ProdGroups/:PROD_GROUP_ID/Products/:PRODUCT_ID/
						resources :seller_products, path: 'products', as: 'products', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :show, :destroy] do
							collection {post 'token_scopes', action: 'scopes_required'}
							member     {post 'token_scopes', action: 'scopes_required'}
						end
					end
					
					
					# Sellers/:SELLER_ID/Products/:PRODUCT_ID/
					resources :seller_products, path: 'products', as: 'products', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :show, :destroy] do
						collection {post 'token_scopes', action: 'scopes_required'}
						member     {post 'token_scopes', action: 'scopes_required'}
					end
					
					
					# Sellers/:SELLER_ID/Brands/:BRAND_ID/
					resources :seller_brands, path: 'brands', as: 'brands', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :show, :destroy] do
						collection {post 'token_scopes', action: 'scopes_required'}
						member     {post 'token_scopes', action: 'scopes_required'}
					end
				end
			end
		end
		
    end
  end
end
