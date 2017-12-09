class RegistrationMailingWorker
  include Sidekiq::Worker

  def perform(mailing_id)

    mailing = Mailing.find(mailing_id)
    template_id = mailing.remote_template_id.to_i
    member = mailing.registration.member
    course = mailing.registration.course
    ticket = mailing.registration.ticket
    payment_url = mailing.registration.payment != nil ? mailing.registration.payment.payment_url : nil

    logger.info("Sending #{mailing.label} mail to member.id #{member.id}")

    sender_email = Setting.mailjet_sender_email_address
    sender_name = Setting.mailjet_sender_email_name
    variables = {
      member_firstname: member.firstname,
      member_lastname: member.lastname,
      course_title: course.title,
      ticket_label: ticket.label,
    }
    variables[:payment_url] = payment_url if payment_url != nil

    options = {
      api_key: Setting.mailjet_public_api_key,
      secret_key: Setting.mailjet_private_api_key
    }

    response = Mailjet::Send.create(
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
            Subject: "Welcome to #{course.title}!",
            Variables: variables
          }
        ]
      },
      options
    )

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
