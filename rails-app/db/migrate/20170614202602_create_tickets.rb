class CreateTickets < ActiveRecord::Migration[5.0]
  def change
    create_table :tickets do |t|
      t.references :course, foreign_key: true
      t.string :label
      t.monetize :price

      t.timestamps
    end
  end
end
