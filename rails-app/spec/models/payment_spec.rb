require "rails_helper"
require "mollie_helper"

describe "Payment" do

  before(:each) do
    @user = FactoryBot.create(:user, role: :admin)
    @tenant_token = @user.tenant.token

    Apartment::Tenant.switch!(@tenant_token)
    Config.create!
    @registration = FactoryBot.create(:registration)
  end

  after(:each) do
    Apartment::Tenant.reset
  end

  context "Creating" do

    context "with valid input" do

      it "queues a remote payment job" do
        expect{
          Payment.create(registration: @registration)
        }.to change(PaymentWorker.jobs, :size).by(1)
      end

    end

  end

end
