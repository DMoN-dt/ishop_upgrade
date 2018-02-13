class CreateUserIdentities < ActiveRecord::Migration
  def change
    create_table :user_identities do |t|
      t.timestamps null: false
	  t.integer  "user_id"
      t.string   "provider",                                  null: false
      t.string   "uid",                                       null: false
      t.datetime "expires_at"
      t.string   "token"
      t.string   "uid_name",        limit: 20
      t.string   "city_name",       limit: 40
      t.string   "photo_url_small"
      t.string   "photo_url_large"
      t.string   "prev_city_name",  limit: 40
      t.boolean  "b_active",                   default: true, null: false
      t.boolean  "b_enabled",                  default: true, null: false
    end
  end
end
