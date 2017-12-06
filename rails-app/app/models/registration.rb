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
    mailing = Mailing.create(
      registration: self,
      remote_template_id: Setting.mailjet_registered_template_id,
      label: "registration confirmation"
    )
    RegistrationMailingWorker.perform_async(mailing.id)
  end

  def send_status_mail
    if self.status == "waitinglist" then
      logger.info("qeueuing waitinglist mail")
      mailing = Mailing.create(
        registration: self,
        remote_template_id: Setting.mailjet_waitinglist_template_id,
        label: "moved to waitinglist"
      )
      RegistrationMailingWorker.perform_async(mailing.id)
    elsif self.status == "accepted" then
      logger.info("qeueuing acceptance mail")
      mailing = Mailing.create(
        registration: self,
        remote_template_id: Setting.mailjet_accepted_template_id,
        label: "acceptance"
      )
      RegistrationMailingWorker.perform_async(mailing.id)
    end
  end

end
