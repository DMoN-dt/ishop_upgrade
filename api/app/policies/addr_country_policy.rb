class AddrCountryPolicy < ApplicationPolicy
	
	def index?
		user.is_allowed_to_profile?
	end
	
	
	def create?
		user.is_admin?
	end
	
	
	def update?
		user.is_admin?
	end
	
	
	def show?
		user.is_admin?
	end
	
	
	def destroy?
		user.is_admin?
	end

	
	private
	
end