class CreateConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :configs do |t|
      t.string :mollie_api_key
      t.string :mollie_redirect_url

      t.string :mailjet_public_api_key
      t.string :mailjet_private_api_key

      t.string :mailjet_sender_email_address
      t.string :mailjet_sender_email_name

      t.string :mailjet_registered_template_id
      t.string :mailjet_registered_subject
      t.string :mailjet_waitinglist_template_id
      t.string :mailjet_waitinglist_subject
      t.string :mailjet_accepted_template_id
      t.string :mailjet_accepted_subject
      t.string :mailjet_paid_subject
      t.string :mailjet_paid_template_id

      t.string :notification_email_address
      t.string :mailjet_notification_email_template_id

      t.timestamps
    end

    drop_table :settings
  end
end
