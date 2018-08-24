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

  enum role: {
    error: 0,
    lead: 1,
    follow: 2,
    solo: 3
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

    logger.info("qeueuing registration mail")
    mailing = Mailing.create(
      registration: self,
      remote_template_id: Setting.mailjet_registered_template_id,
      label: :registration,
      target: :member
    )
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

      logger.info("qeueuing waitinglist mail")
      mailing = Mailing.create(
        registration: self,
        remote_template_id: Setting.mailjet_waitinglist_template_id,
        label: :waitinglist,
        target: :member
      )
    elsif self.status == "accepted" then
      logger.info("notifying admin about acceptance")
      mailing = Mailing.create(
        registration: self,
        remote_template_id: Setting.mailjet_notification_email_template_id,
        label: :acceptance,
        target: :admin
      )

      logger.info("qeueuing acceptance mail")
      mailing = Mailing.create(
        registration: self,
        remote_template_id: Setting.mailjet_accepted_template_id,
        label: :acceptance,
        target: :member
      )
    end
  end

end
