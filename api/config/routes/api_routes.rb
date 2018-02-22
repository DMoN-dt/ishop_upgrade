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
					
					# Sellers/:SELLER_ID/Pricing_Fixed/:PRICING_FIXED_PRICE_ID/
					resources :seller_products_fixed_prices, path: 'pricing_fixed', as: 'pricing_fixed', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :show, :destroy] do
						collection {post 'token_scopes', action: 'scopes_required'}
						member     {post 'token_scopes', action: 'scopes_required'}
					end
					
					# Sellers/:SELLER_ID/Pricing_Maths/:PRICING_MATH_ID/
					resources :seller_pricing_maths, path: 'pricing_maths', as: 'pricing_maths', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :show, :destroy] do
						collection {post 'token_scopes', action: 'scopes_required'}
						member     {post 'token_scopes', action: 'scopes_required'}
					end
					
					# Sellers/:SELLER_ID/Pricing_Prices/:PRICING_PRICE_ID/
					resources :seller_pricing_prices, path: 'pricing_prices', as: 'pricing_prices', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :show, :destroy] do
						collection do
							post 'token_scopes', action: 'scopes_required'
							
							post 'info', action: 'info'
						end
						
						member     {post 'token_scopes', action: 'scopes_required'}
					end
					
					# Sellers/:SELLER_ID/Pricing_Rules/:PRICING_RULE_ID/
					resources :seller_pricing_rules, path: 'pricing_rules', as: 'pricing_rules', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :show, :destroy] do
						collection do
							post 'token_scopes', action: 'scopes_required'
							
							post 'info', action: 'info'
						end
						
						member     {post 'token_scopes', action: 'scopes_required'}
					end
					
					
					# concern :commentable do
					#   resources :comments
					# end
					
					# Sellers/:SELLER_ID/ProdGroups/:PROD_GROUP_ID/ #, concerns: :commentable
					resources :seller_products_groups, path: 'prodgroups', as: 'prodgroups', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :update, :destroy] do
						collection do
							post 'token_scopes',	action: 'scopes_required'
							
							post 'update',			action: 'update_groups'
						end
						
						member do
							post 'token_scopes',	action: 'scopes_required'
							
							post 'parents',			action: 'group_parents'
							post 'parents_tree', 	action: 'group_parents_tree'
						end
						
						
						# Sellers/:SELLER_ID/ProdGroups/:PROD_GROUP_ID/Products/:PRODUCT_ID/  [FULL ACCESS TO PRODUCT]
						resources :seller_products, path: 'products', as: 'products', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :show, :update, :destroy] do
							collection do
								post 'token_scopes',	action: 'scopes_required'
								post 'images',			action: 'fetch_images'
							end
						
							member do
								post 'token_scopes',	action: 'scopes_required'
								post 'suppliers',		action: 'fetch_suppliers_availability'
								post 'instock',			action: 'fetch_instock_availability'
								post 'pricing_math',	action: 'fetch_pricing_math'
								post 'fixed_prices',	action: 'fetch_fixed_prices'
							end
						end
					end
					
					
					# Sellers/:SELLER_ID/Products/:PRODUCT_ID/  [LITE ACCESS TO PRODUCT]
					resources :seller_products, path: 'products', as: 'products', :constraints => {:id => /[0-9]+/}, only: [:index, :show] do
						collection do
							post 'token_scopes', 	action: 'scopes_required'
							post 'images',			action: 'fetch_images'
						end
						
						member do
							post 'token_scopes',	action: 'scopes_required'
							post 'suppliers',		action: 'fetch_suppliers_availability'
							post 'instock',			action: 'fetch_instock_availability'
							post 'pricing_math',	action: 'fetch_pricing_math'
							post 'fixed_prices',	action: 'fetch_fixed_prices'
						end
					end
					
					
					# Sellers/:SELLER_ID/Brands/:BRAND_ID/
					resources :seller_brands, path: 'brands', as: 'brands', :constraints => {:id => /[0-9]+/}, only: [:index, :create, :show, :destroy] do
						collection {post 'token_scopes', action: 'scopes_required'}
						member     {post 'token_scopes', action: 'scopes_required'}
					end
					
					# Sellers/:SELLER_ID/Suppliers/:SUPPLIER_ID/
					resources :seller_suppliers, path: 'suppliers', as: 'suppliers', :constraints => {:id => /[0-9]+/}, only: [:index, :show] do
						collection do
							post 'token_scopes', 	action: 'scopes_required'
							
							# Sellers/:SELLER_ID/Suppliers/Products/:SELLER_SUPPLIER_PRODUCT_ID/
							# resources :seller_suppliers_products, path: 'products', as: 'products', :constraints => {:id => /[0-9]+/}, only: [:index, :show] do
							# 	collection do
							# 		post 'token_scopes', 			action: 'scopes_required'
							# 		post 'seller_availability',		action: 'fetch_seller_products_availability'
							# 	end
							# 	
							# 	member     {post 'token_scopes', action: 'scopes_required'}
							# end
						end
						
						member     {post 'token_scopes', action: 'scopes_required'}
					end
				end
			end
		end
		
		
		# resources do
		# 	collection do
		# 	end
		# 	
		# 	member do
		# 	end
		# end
    end
  end
end
