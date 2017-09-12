class CreateMailings < ActiveRecord::Migration[5.0]
  def change
    create_table :mailings do |t|
      t.references :registration, foreign_key: true
      t.integer :status
      t.string :remote_id
      t.string :remote_template_id
      t.json :arguments

      t.timestamps
    end
  end
end
