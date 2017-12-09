require "rails_helper"
require "mollie_helper"

describe "When a member registers for a course" do

  context "with correct settings" do

    before(:each) do
      @member = FactoryBot.create(:member)
      @course = FactoryBot.create(:course)
      @ticket = FactoryBot.create(:ticket, course: @course)

      stub_payment_creation_request
    end

    it "sends a registration email" do
      expect{
        @course.register(@member, {}, true, @ticket)
      }.to change{RegistrationMailingWorker.jobs.length}.by(1)

      mailing = Mailing.last
      expect(mailing.label).to eq("registration")
    end

    pending "notifies the admin"

    pending "logs to the audit log"

  end

end
