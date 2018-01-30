class MailjetWorker
  include Sidekiq::Worker

  def perform(mailing_id)
    mailing = Mailing.find(mailing_id)

    sender_email = Setting.mailjet_sender_email_address
    sender_name = Setting.mailjet_sender_email_name
    options = {
      api_key: Setting.mailjet_public_api_key,
      secret_key: Setting.mailjet_private_api_key
    }
    variables = get_variables(mailing)

    if mailing.target == "admin"
      response = notifiy_admin(mailing, options, variables, sender_email, sender_name)
    elsif mailing.target == "member"
      response = notify_member(mailing, options, variables, sender_email, sender_name)
    end

    store_result(mailing, response, variables)
  end

  def notifiy_admin(mailing, options, variables, sender_email, sender_name)
    logger.info("Sending #{mailing.label} notification mail")
    template_id = mailing.remote_template_id.to_i
    member = mailing.registration.member

    subject = mailing.label == "registration" ? "New registration" : "Registration modified"

    return  Mailjet::Send.create(
      {
        messages: [
          {
            From: {
              Email: sender_email,
              Name: sender_name
            },
            To: [
              {
                Email: member.email,
                Name: member.full_name
              }
            ],
            TemplateID: template_id,
            TemplateLanguage: true,
            Subject: subject,
            Variables: variables
          }
        ]
      },
      options
    )
  end

  def notify_member(mailing, options, variables, sender_email, sender_name)
    logger.info("Sending #{mailing.label} member mail")
    template_id = mailing.remote_template_id.to_i
    member = mailing.registration.member

    course = mailing.registration.course
    status = mailing.registration.status

    subject = get_subject(mailing)

    return  Mailjet::Send.create(
      {
        messages: [
          {
            From: {
              Email: sender_email,
              Name: sender_name
            },
            To: [
              {
                Email: member.email,
                Name: member.full_name
              }
            ],
            TemplateID: template_id,
            TemplateLanguage: true,
            Subject: subject,
            Variables: variables
          }
        ]
      },
      options
    )

  end

  def get_subject(mailing)
    case mailing.label
    when "registration"
      return Setting.mailjet_registered_subject
    when "payment"
      return Setting.mailjet_paid_subject
    when "waitinglist"
      return Setting.mailjet_waitinglist_subject
    when "acceptance"
      return Setting.mailjet_accepted_subject
    end
  end

  def get_variables(mailing)
    member = mailing.registration.member
    course = mailing.registration.course
    ticket = mailing.registration.ticket
    status = mailing.registration.status
    payment_url = mailing.registration.payment != nil ? mailing.registration.payment.payment_url : nil

    logger.info("Sending #{mailing.label} mail to member.id #{member.id}")

    variables = {
      member_firstname: member.firstname,
      member_lastname: member.lastname,
      course_title: course.title,
      ticket_label: ticket.label,
      registration_status: status
    }
    variables[:payment_url] = payment_url if payment_url != nil

    return variables
  end

  def store_result(mailing, response, variables)
    message = response.Messages[0]

    mailing.arguments = variables
    if message[:Status] == "success" then
      mailing.status = :sent
      mailing.remote_id = message[:To][0][:MessageID]
    else
      mailing.status = :failed
    end
    mailing.save!
  end

end
