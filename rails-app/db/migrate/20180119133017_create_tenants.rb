class CreateTenants < ActiveRecord::Migration[5.0]
  def change
    create_table :tenants do |t|
      t.string :label
      t.string :token

      t.timestamps
    end
  end
end
