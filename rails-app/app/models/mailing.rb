class Mailing < ApplicationRecord
  belongs_to :registration

  enum status: {
    created: 0,
    sent: 1,
    failed: 2
  }

  enum label: {
    unknown: 0,
    registration: 1,
    payment: 2,
    waitinglist: 3,
    acceptance: 4
  }

  enum target: {
    member: 1,
    admin: 2
  }

  after_create :queue_mailing

  def queue_mailing
    MailjetWorker.perform_async(self.id)
  end

end
