require "rails_helper"

describe "When a registration is put onto the waitinglist", type: :request do

  context "with correct settings" do

    context "while it was previously in triage status" do

      before(:each) do
        @registration = FactoryBot.create(:registration, status: :triage)
      end

      it "sends a waitinglist email" do
        expect{
          @registration.update!(status: :waitinglist)
        }.to change{RegistrationMailingWorker.jobs.length}.by(1)

        mailing = Mailing.last
        expect(mailing.label).to eq("waitinglist")
      end

      pending "notifies the admin"

      pending "logs to the audit log"

    end

    context "while it was previously in accepted status" do

      before(:each) do
        @registration = FactoryBot.create(:registration, status: :accepted)
      end

      it "sends a waitinglist email" do
        expect{
          @registration.update!(status: :waitinglist)
        }.to change{RegistrationMailingWorker.jobs.length}.by(1)

        mailing = Mailing.last
        expect(mailing.label).to eq("waitinglist")
      end

      pending "notifies the admin"

      pending "logs to the audit log"

    end

  end

end
