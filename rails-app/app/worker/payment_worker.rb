class PaymentWorker
  include Sidekiq::Worker

  class IncorrectConfigException < StandardError
  end


  def perform(payment_id, webhook_url)
    begin
      payment = Payment.find(payment_id)
      registration = payment.registration

      logger.info("Creating payment for registration #{registration.id}")

      check_config(payment, Setting.mollie_api_key)

      mollie = Mollie::API::Client.new(Setting.mollie_api_key)
      mollie_payment = mollie.payments.create(
        amount:       registration.ticket.price.fractional * 0.01,
        description:  registration.course.title,
        redirect_url: "#{Setting.mollie_redirect_url}?payment=#{payment.id}",
        webhook_url:  webhook_url
      )

      payment.remote_id = mollie_payment.id
      payment.payment_url = mollie_payment.payment_url
      payment.status = :submitted
      payment.save!

    rescue IncorrectConfigException
      payment.status = :failed
      payment.save!
      return
    end
  end

  def check_config(payment, api_key)
    raise IncorrectConfigException, "No api key" if api_key == nil
  end

end
