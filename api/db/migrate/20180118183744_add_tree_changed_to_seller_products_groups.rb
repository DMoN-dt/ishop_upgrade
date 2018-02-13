class AddTreeChangedToSellerProductsGroups < ActiveRecord::Migration[5.1]
  def change
	add_column :seller_products_groups, :tree_changed, :boolean, null: false, default: false
  end
end
