class PaidMailingWorker
  include Sidekiq::Worker

  def perform(mailing_id)

  end

end
