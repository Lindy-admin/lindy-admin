class RegistrationsHaveAStatus < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :status,  :integer, default: 0
  end
end
