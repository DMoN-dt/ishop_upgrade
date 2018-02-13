class SellerProductsGroupPolicy < ApplicationPolicy
	
	def index?
		user.is_allowed_to_ecommerce?
	end
	
	
	def create?
		user.is_allowed_to_ecommerce?
	end
	
	
	def update_groups?
		user.is_allowed_to_ecommerce?
	end
	
	
	def group_parents?
		user.is_allowed_to_ecommerce?
	end
	
	
	def group_parents_tree?
		user.is_allowed_to_ecommerce?
	end
	
	
	def edit?
		user_allowed_to_object?(user, record, [:edit])
	end
	
	
	def destroy?
		user_allowed_to_object?(user, record, [:delete])
	end

	
	private
	
	def user_allowed_to_object? (user, record, access_arr)
		return false if(!user.is_allowed_to_ecommerce?)
		record.create_acl(user)
		return record.has_access?(access_arr)
	end

end