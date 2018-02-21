class Payment < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :registration

  enum status: {
    created: 0,
    submitted: 1,
    paid: 2,
    aborted: 3,
    failed: 4
  }

  after_create :submit_to_payment_provider
  after_save :send_confirmation_email, if: :status_changed?

  def submit_to_payment_provider
    logger.info("qeueuing payment creation")
    PaymentWorker.perform_async(
      self.id,
      payment_webhook_url(Apartment::Tenant.current, self.id, host: Rails.application.config.webhook_hostname)
    )
  end

  def send_confirmation_email
    if self.status == "paid" then
      logger.info("qeueuing confirmation mail")
      mailing = Mailing.create(
        registration: self.registration,
        remote_template_id: Setting.mailjet_paid_template_id,
        label: :payment,
        target: :member
      )
      MailjetWorker.perform_async(mailing.id)
    end
  end

end
