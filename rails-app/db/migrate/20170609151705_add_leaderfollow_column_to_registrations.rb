class AddLeaderfollowColumnToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :role, :boolean, default: false, null: false
  end
end
