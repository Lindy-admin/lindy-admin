class MailsHaveATarget < ActiveRecord::Migration[5.0]
  def change
    add_column :mailings, :target, :integer, default: 1
  end
end
