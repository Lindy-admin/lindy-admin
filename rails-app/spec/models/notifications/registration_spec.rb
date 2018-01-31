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

    it "will send an email confirmation" do
      expect {
        @course.register(@member, {}, true, @ticket, {})
      }.to change{Mailing.where(target: :member, label: :registration).count}.by(1)

      mailing = Mailing.where(target: :member, label: :registration).last
      expect(MailjetWorker).to have_enqueued_sidekiq_job(mailing.id)
    end

    it "notifies the admin" do
      expect {
        @course.register(@member, {}, true, @ticket, {})
      }.to change{Mailing.where(target: :admin, label: :registration).count}.by(1)

      mailing = Mailing.where(target: :admin, label: :registration).last
      expect(MailjetWorker).to have_enqueued_sidekiq_job(mailing.id)
    end


    pending "logs to the audit log"

  end

end
