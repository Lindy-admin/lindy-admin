class AddTenantToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :tenant, :string, null: false
  end
end
