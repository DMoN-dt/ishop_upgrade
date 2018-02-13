class SellerBrandPolicy < ApplicationPolicy
	
	def index?
		user.is_allowed_to_ecommerce?
	end
	
	
	def create?
		user.is_allowed_to_ecommerce?
	end
	
	
	def update?
		user.is_allowed_to_ecommerce?
	end
	
	
	def show?
		user.is_allowed_to_ecommerce?
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