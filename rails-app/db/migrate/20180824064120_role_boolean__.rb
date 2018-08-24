class RoleBoolean < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :role_int, :integer, default: 0

    execute "UPDATE registrations SET role_int = CASE WHEN role=true THEN 1 ELSE 2 END;"

    remove_column :registrations, :role
    rename_column :registrations, :role_int, :role
  end
end
