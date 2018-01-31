class AddAdditionalDataToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :additional, :json
  end
end
