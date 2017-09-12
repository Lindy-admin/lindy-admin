class PaidMailingWorker
  include Sidekiq::Worker

  def perform(mailing_id)

    mailing = Mailing.find(mailing_id)
    member = mailing.registration.member
    course = mailing.registration.course

    response = Mailjet::Send.create(
      messages: [
        {
          From: {
            Email: "todorus@todorus.com",
            Name: "Theo is testing emails"
          },
          To: [
            {
              Email: member.email,
              Name: member.full_name
            }
          ],
          TemplateID: 210827,
          TemplateLanguage: true,
          Subject: "Welcome to #{course.title}!",
          Variables: {
            member_firstname: member.firstname,
            member_lastname: member.lastname,
            course_title: course.title
          }
        }
      ]
    )

    message = response.Messages[0]

    if message[:Status] == "success" then
      mailing.status = :sent
      mailing.remote_id = message[:To][0][:MessageID]
    else
      mailing.status = :failed
    end
    mailing.save!

  end

end
