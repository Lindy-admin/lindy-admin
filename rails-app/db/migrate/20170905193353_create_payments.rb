class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.references :registration, foreign_key: {on_delete: :cascade}
      t.string :remote_id
      t.string :payment_url
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
