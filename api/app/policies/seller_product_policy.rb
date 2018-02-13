class SellerProductPolicy < ApplicationPolicy
	
	def index?
		user.is_allowed_to_ecommerce?
	end
	
	
	def create?
		user.is_allowed_to_ecommerce?
	end
	
	
	def update_products?
		user.is_allowed_to_ecommerce?
	end
	
	
	def show?
		user_allowed_to_object?(user, record, [:gen_some_access])
	end
	
	
	def destroy?
		user_allowed_to_object?(user, record, [:delete])
	end
	
	
	
	def show?
		user.is_allowed_to_profile?
	end
	
	def show_archived?
		user.is_allowed_to_profile?
	end
	
	#def images_edit?
	#	user_allowed_to_object?(user, record, [:edit])
	#end
	
	def images_add?
		user_allowed_to_object?(user, record, [:edit])
	end
	
	def images_delete?
		user_allowed_to_object?(user, record, [:edit])
	end
	
	
	def import?
		user.is_allowed_to_ecommerce?
	end
	
	def import_price?
		user.is_allowed_to_ecommerce?
	end
	
	def import_price_groups_save?
		user.is_allowed_to_ecommerce?
	end
	
	def import_price_products?
		user.is_allowed_to_ecommerce?
	end
	
	def import_price_products_save?
		user.is_allowed_to_ecommerce?
	end
	
	def update_with_suppliers?
		user.is_allowed_to_ecommerce?
	end
	
	def update_with_suppliers_save?
		user.is_allowed_to_ecommerce?
	end
	
	
	private
	
	def user_allowed_to_object? (user, record, access_arr)
		return false if(!user.is_allowed_to_ecommerce?)
		record.create_acl(user)
		return record.has_access?(access_arr)
	end
	
end