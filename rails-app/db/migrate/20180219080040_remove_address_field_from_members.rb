class RemoveAddressFieldFromMembers < ActiveRecord::Migration[5.0]
  def change
    remove_column :members, :address
  end
end
