class PaymentWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  class IncorrectConfigException < StandardError
  end

  def perform(tenant_id, payment_id, webhook_url)

    Apartment::Tenant.switch!(tenant_id)

    begin
      payment = Payment.find(payment_id)
      registration = payment.registration

      logger.info("Creating payment for registration #{registration.id}")

      check_config(payment, Config.first.mollie_api_key)

      mollie = Mollie::API::Client.new(Config.first.mollie_api_key)
      mollie_payment = mollie.payments.create(
        amount:       registration.ticket.price.fractional * 0.01,
        description:  registration.course.title,
        redirect_url: "#{Config.first.mollie_redirect_url}?payment=#{payment.id}",
        webhook_url:  webhook_url
      )

      payment.remote_id = mollie_payment.id
      payment.payment_url = mollie_payment.payment_url
      payment.status = :submitted
      payment.save!

      logger.info("Setting payment status for registration #{registration.id} to #{payment.status}")

    rescue IncorrectConfigException
      payment.status = :failed
      payment.save!
    end
  end

  def check_config(payment, api_key)
    raise IncorrectConfigException, "No api key" if api_key == nil || api_key == ""
  end

end
