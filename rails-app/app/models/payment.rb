class Payment < ApplicationRecord
  belongs_to :registration

  enum status: {
    created: 0,
    submitted: 1,
    paid: 2,
    aborted: 3
  }

  after_create :submit_to_payment_provider
  after_save :send_confirmation_email, if: :status_changed?

  def submit_to_payment_provider
    mollie = Mollie::API::Client.new(Setting.mollie_api_key)
    mollie_payment = mollie.payments.create(
      amount:       registration.ticket.price.fractional * 0.01,
      description:  registration.course.title,
      redirect_url: "#{Setting.mollie_redirect_url}?payment=#{self.id}",
      webhook_url:  "https://#{Rails.application.config.webhook_hostname}/payments/webhook"
    )

    self.remote_id = mollie_payment.id
    self.payment_url = mollie_payment.payment_url
    self.status = :submitted
    self.save!
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
