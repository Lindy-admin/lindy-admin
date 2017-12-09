require "rails_helper"

describe "When a registration is accepted" do

  context "with correct settings" do

    context "while it was previously in triage status" do

      before(:each) do
        @registration = FactoryBot.create(:registration, status: :triage)
      end

      it "sends an acceptance email" do
        expect{
          @registration.update!(status: :accepted)
        }.to change{RegistrationMailingWorker.jobs.length}.by(1)

        mailing = Mailing.last
        expect(mailing.label).to eq("acceptance")
      end

      pending "notifies the admin"

      pending "logs to the audit log"

    end

    context "while it was previously in waitinglist status" do

      before(:each) do
        @registration = FactoryBot.create(:registration, status: :waitinglist)
      end

      it "sends an acceptance email" do
        expect{
          @registration.update!(status: :accepted)
        }.to change{RegistrationMailingWorker.jobs.length}.by(1)

        mailing = Mailing.last
        expect(mailing.label).to eq("acceptance")
      end

      pending "notifies the admin"

      pending "logs to the audit log"

    end

  end

end
