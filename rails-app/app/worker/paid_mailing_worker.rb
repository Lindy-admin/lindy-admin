class PaidMailingWorker
  include Sidekiq::Worker

  def perform(mailing_id)

    mailing = Mailing.find(mailing_id)
    member = mailing.registration.member
    course = mailing.registration.course

    sender_email = "todorus@todorus.com"
    sender_name = "Theo is testing emails"
    template_id = 210827
    variables = {
      member_firstname: member.firstname,
      member_lastname: member.lastname,
      course_title: course.title
    }

    response = Mailjet::Send.create(
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
