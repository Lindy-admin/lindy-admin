require "rails_helper"

describe "When registering for a course", type: :request do

  before(:all) do

    @course = FactoryBot.create(:course)
    @ticket = FactoryBot.create(:ticket, course: @course)

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

    it "will create a new registration" do
      expect {
        post registrations_path, params: params
      }.to change{Registration.count}.by(1)
    end

    pending "will create a payment for the registration"

    pending "will send an email with payment instructions"

  end

end
