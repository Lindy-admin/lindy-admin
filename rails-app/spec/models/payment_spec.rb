require "rails_helper"
require "mollie_helper"

describe "Payment" do

  before(:each) do
    @registration = FactoryBot.create(:registration)
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
