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
    logger.info("notifying admin about registration")
    mailing = Mailing.create(
      registration: self,
      remote_template_id: Setting.mailjet_notification_email_template_id,
      label: :registration,
      target: :admin
    )
    RegistrationMailingWorker.perform_async(mailing.id)

    logger.info("qeueuing registration mail")
    mailing = Mailing.create(
      registration: self,
      remote_template_id: Setting.mailjet_registered_template_id,
      label: :registration,
      target: :member
    )
    RegistrationMailingWorker.perform_async(mailing.id)
  end

  def send_status_mail
    if self.status == "waitinglist" then
      logger.info("notifying admin about waitinglist")
      mailing = Mailing.create(
        registration: self,
        remote_template_id: Setting.mailjet_notification_email_template_id,
        label: :waitinglist,
        target: :admin
      )
      RegistrationMailingWorker.perform_async(mailing.id)

      logger.info("qeueuing waitinglist mail")
      mailing = Mailing.create(
        registration: self,
        remote_template_id: Setting.mailjet_waitinglist_template_id,
        label: :waitinglist,
        target: :member
      )
      RegistrationMailingWorker.perform_async(mailing.id)
    elsif self.status == "accepted" then
      logger.info("notifying admin about acceptance")
      mailing = Mailing.create(
        registration: self,
        remote_template_id: Setting.mailjet_notification_email_template_id,
        label: :acceptance,
        target: :admin
      )
      RegistrationMailingWorker.perform_async(mailing.id)

      logger.info("qeueuing acceptance mail")
      mailing = Mailing.create(
        registration: self,
        remote_template_id: Setting.mailjet_accepted_template_id,
        label: :acceptance,
        target: :member
      )
      RegistrationMailingWorker.perform_async(mailing.id)
    end
  end

end
