class Registration < ApplicationRecord
  belongs_to :member
  belongs_to :course
  belongs_to :ticket
  has_one :payment, dependent: :destroy
  has_many :mailings, dependent: :destroy

  enum status: {
    created: 0,
    triage: 1,
    waitinglist: 2,
    accepted: 3
  }

  after_create :send_created_mail
  after_save :send_status_mail, if: :status_changed?

  def send_created_mail
    mailing = Mailing.create(registration: self)
    RegisteredMailingWorker.perform_async(mailing.id)
  end

  def send_status_mail
    if self.status == "waitinglist" then
      logger.info("qeueuing waitinglist mail")
      mailing = Mailing.create(registration: self)
      WaitinglistMailingWorker.perform_async(mailing.id)
    elsif self.status == "accepted" then
      logger.info("qeueuing acceptance mail")
      mailing = Mailing.create(registration: self)
      AcceptedMailingWorker.perform_async(mailing.id)
    end
  end

end
