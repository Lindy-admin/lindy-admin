class MailingsHaveLabels < ActiveRecord::Migration[5.0]
  def change
    add_column :mailings, :label, :string
  end
end
