class Payment < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :registration

  enum status: {
    created: 0,
    submitted: 1,
    paid: 2,
    aborted: 3,
    failed: 4,
    cancelled: 5,
    pending: 6,
    expired: 7,
    paidout: 8,
    refunded: 9,
    charged_back: 10,
    unknown: 11
  }

  # the job may get started to when using after_create, so use after_commit instead
  # see https://github.com/mperham/sidekiq/issues/322
  after_commit :submit_to_payment_provider, on: :create

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
    end
  end

end
