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
        }.to change{Mailing.where(target: :member, label: :acceptance).count}.by(1)

        mailing = Mailing.where(target: :member, label: :acceptance).last
        expect(RegistrationMailingWorker).to have_enqueued_sidekiq_job(mailing.id)
      end

      it "notifies the admin" do
        expect {
          @registration.update!(status: :accepted)
        }.to change{Mailing.where(target: :admin, label: :acceptance).count}.by(1)

        mailing = Mailing.where(target: :admin, label: :acceptance).last
        expect(RegistrationMailingWorker).to have_enqueued_sidekiq_job(mailing.id)
      end

      pending "logs to the audit log"

    end

    context "while it was previously in waitinglist status" do

      before(:each) do
        @registration = FactoryBot.create(:registration, status: :waitinglist)
      end

      it "sends an acceptance email" do
        expect{
          @registration.update!(status: :accepted)
        }.to change{Mailing.where(target: :member, label: :acceptance).count}.by(1)

        mailing = Mailing.where(target: :member, label: :acceptance).last
        expect(RegistrationMailingWorker).to have_enqueued_sidekiq_job(mailing.id)
      end

      it "notifies the admin" do
        expect {
          @registration.update!(status: :accepted)
        }.to change{Mailing.where(target: :admin, label: :acceptance).count}.by(1)

        mailing = Mailing.where(target: :admin, label: :acceptance).last
        expect(RegistrationMailingWorker).to have_enqueued_sidekiq_job(mailing.id)
      end

      pending "logs to the audit log"

    end

  end

end
