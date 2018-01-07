class PaymentsController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:webhook, :status]

  def webhook

    begin

        payment = Payment.where(remote_id: params[:id]).first
        if payment == nil
          raise ActiveRecord::RecordNotFound
        end

        mollie = Mollie::API::Client.new(Setting.mollie_api_key)
        mollie_payment = mollie.payments.get payment.remote_id

        if mollie_payment.paid?
            payment.status = :paid
        elsif !mollie_payment.open?
            payment.status = :aborted
        end
        payment.save!
    rescue Mollie::API::Exception => e
        render text: "Failed", status: 500
    end

  end

  def status
    @payment = Payment.find(params[:id])
  end

end
