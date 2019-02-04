class MailjetWorker
  include Sidekiq::Worker

  class IncorrectConfigException < StandardError
  end


  def perform(tenant_id, mailing_id)

    Apartment::Tenant.switch!(tenant_id)

    begin
      mailing = Mailing.find(mailing_id)

      sender_email = Config.first.mailjet_sender_email_address
      sender_name = Config.first.mailjet_sender_email_name
      options = {
        api_key: Config.first.mailjet_public_api_key,
        secret_key: Config.first.mailjet_private_api_key
      }
      variables = get_variables(mailing)

      check_config(mailing, options, variables, sender_email, sender_name)
      if mailing.target == "admin"
        response = notify_admin(mailing, options, variables, sender_email, sender_name)
      elsif mailing.target == "member"
        response = notify_member(mailing, options, variables, sender_email, sender_name)
      end

      store_result(mailing, response, variables)
    rescue IncorrectConfigException
      mailing.status = :failed
      mailing.save!
      return
    end
  end

  def check_config(mailing, options, variables, sender_email, sender_name)
    raise IncorrectConfigException, "No api key" if options[:api_key] == nil || options[:api_key] == ""
    raise IncorrectConfigException, "No api secret" if options[:secret_key] == nil || options[:secret_key] == ""
    raise IncorrectConfigException, "No template id" if mailing.remote_template_id == nil || mailing.remote_template_id == ""
    raise IncorrectConfigException, "No sender email" if sender_email == nil || sender_email == ""
  end

  def notify_admin(mailing, options, variables, sender_email, sender_name)
    raise IncorrectConfigException, "No notification email" if Config.first.notification_email_address == nil

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
                Email: Config.first.notification_email_address,
                Name: "Lindy Administrator"
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
      return Config.first.mailjet_registered_subject
    when "payment"
      return Config.first.mailjet_paid_subject
    when "waitinglist"
      return Config.first.mailjet_waitinglist_subject
    when "acceptance"
      return Config.first.mailjet_accepted_subject
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
    else
      mailing.status = :failed
    end
    mailing.remote_id = message[:To][0][:MessageID]
    mailing.save!
  end

end
