require "rails_helper"
require "mollie_helper"

describe "When registering for a course", type: :request do

  before(:each) do
    Setting.mailjet_sender_email_address = "some@email.com"
    Setting.mailjet_sender_email_name = "some_email_name"
    Setting.mailjet_paid_template_id = 1
    Setting.save

    @course = FactoryBot.create(:course)
    @ticket = FactoryBot.create(:ticket, course: @course)

    stub_payment_creation_request
  end

  context "while providing the correct input" do

    let (:params) do
      {
        firstname: "firstname",
        lastname: "lastname",
        course: @course.id,
        ticket: @ticket.id,
        role: 1,
        email: "test@email.com"
      }
    end

    it "will create a new Registration" do
      expect {
        post registrations_path, params: params
      }.to change{Registration.count}.by(1)
    end

    it "will put the Registration in the triage status" do
      post registrations_path, params: params

      registration = Registration.last
      expect(registration.status).to eq("triage")
    end

    it "will create a Payment for the Registration" do
      expect {
        post registrations_path, params: params
      }.to change{Payment.count}.by(1)
    end

    pending "logs to the audit log"

  end

end
