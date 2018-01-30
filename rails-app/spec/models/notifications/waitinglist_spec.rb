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
        }.to change{Mailing.where(target: :member, label: :waitinglist).count}.by(1)

        mailing = Mailing.where(target: :member, label: :waitinglist).last
        expect(MailjetWorker).to have_enqueued_sidekiq_job(mailing.id)
      end

      it "notifies the admin" do
        expect {
          @registration.update!(status: :waitinglist)
        }.to change{Mailing.where(target: :admin, label: :waitinglist).count}.by(1)

        mailing = Mailing.where(target: :admin, label: :waitinglist).last
        expect(MailjetWorker).to have_enqueued_sidekiq_job(mailing.id)
      end

      pending "logs to the audit log"

    end

    context "while it was previously in accepted status" do

      before(:each) do
        @registration = FactoryBot.create(:registration, status: :accepted)
      end

      it "sends a waitinglist email" do
        expect{
          @registration.update!(status: :waitinglist)
        }.to change{Mailing.where(target: :member, label: :waitinglist).count}.by(1)

        mailing = Mailing.where(target: :member, label: :waitinglist).last
        expect(MailjetWorker).to have_enqueued_sidekiq_job(mailing.id)
      end

      it "notifies the admin" do
        expect {
          @registration.update!(status: :waitinglist)
        }.to change{Mailing.where(target: :admin, label: :waitinglist).count}.by(1)

        mailing = Mailing.where(target: :admin, label: :waitinglist).last
        expect(MailjetWorker).to have_enqueued_sidekiq_job(mailing.id)
      end

      pending "logs to the audit log"

    end

  end

end
