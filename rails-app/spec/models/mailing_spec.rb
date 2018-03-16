

require "rails_helper"
require "mollie_helper"

describe "Mailing" do

  context "Creating" do

    context "with valid input" do

      before(:each) do
        @registration = FactoryBot.create(:registration, status: :triage)
      end

      it "queues the worker" do
        expect {
          Mailing.create(
            registration: @registration,
            remote_template_id: 1,
            label: :registration,
            target: :member
          )
        }.to change(MailjetWorker.jobs, :size).by(1)


      end

      it "gives the right arguments to the worker" do
        mailing = Mailing.create(
          registration: @registration,
          remote_template_id: 1,
          label: :registration,
          target: :member
        )

        expect(MailjetWorker).to have_enqueued_sidekiq_job(mailing.id)
      end

    end

  end

end
