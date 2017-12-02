class RegisteredMailingWorker
  include Sidekiq::Worker

  def perform(mailing_id)

    mailing = Mailing.find(mailing_id)
    member = mailing.registration.member
    course = mailing.registration.course
    ticket = mailing.registration.ticket

    logger.info("Sending registered mail to member.id #{member.id}")

    sender_email = Setting.mailjet_sender_email
    sender_name = Setting.mailjet_sender_name
    template_id = Setting.mailjet_registered_template_id.to_i
    variables = {
      member_firstname: member.firstname,
      member_lastname: member.lastname,
      course_title: course.title,
      ticket_label: ticket.label,
      payment_url: payment_url
    }

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
