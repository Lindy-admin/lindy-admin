

require "rails_helper"
require "mollie_helper"

describe "Mailing" do

  context "Creating" do

    context "with valid input" do

      let(:perform) do
        Apartment::Tenant.switch!(@tenant_token)
        mailing = Mailing.create(
          registration: @registration,
          remote_template_id: 1,
          label: :registration,
          target: :member
        )
        mailing_id = mailing.id
        Apartment::Tenant.reset

        return mailing_id
      end

      before(:each) do
        @user = FactoryBot.create(:user, role: :admin)
        @tenant_token = @user.tenant.token

        Apartment::Tenant.switch!(@tenant_token)
        Config.create!
        @registration = FactoryBot.create(:registration, status: :triage)
        Apartment::Tenant.reset
      end

      it "queues the worker" do
        expect {
          perform
        }.to change(MailjetWorker.jobs, :size).by(1)


      end

      it "gives the right arguments to the worker" do
        mailing_id = perform

        expect(MailjetWorker).to have_enqueued_sidekiq_job(@tenant_token, mailing_id)
      end

    end

  end

end
