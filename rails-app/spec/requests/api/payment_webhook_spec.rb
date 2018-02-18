require "rails_helper"
require "mollie_helper"

describe "When updating a payment status through the webhook" do

  before :each do
    stub_payment_creation_request

    user = FactoryBot.create(:user, role: :admin)
    @tenant = user.tenant
    Apartment::Tenant.switch!(@tenant.token)
    registration = FactoryBot.create(:registration)
    @payment = FactoryBot.create(:payment, registration: registration, status: :submitted)
    Apartment::Tenant.reset
  end

  context "with a payment that changed to paid" do

    before :each do
      stub_payment_webhook_request(@payment.remote_id, "paid")
    end

    it "changes the payment status to paid" do
      expect {
        post payment_webhook_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      }.to change {
        Apartment::Tenant.switch!(@tenant.token)
        @payment.reload
        status = @payment.status
        Apartment::Tenant.reset
        status
      }.to("paid")

    end

    it "returns a NO CONTENT status" do
      post payment_webhook_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.status).to eq(204)
      expect(response.body).to eq("")
    end

  end

  context "with a payment that changed to cancelled" do

    before :each do
      stub_payment_webhook_request(@payment.remote_id, "cancelled")
    end

    it "changes the payment status to aborted" do
      expect {
        post payment_webhook_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      }.to change {
        Apartment::Tenant.switch!(@tenant.token)
        @payment.reload
        status = @payment.status
        Apartment::Tenant.reset
        status
      }.to("aborted")

    end

    it "returns a NO CONTENT status" do
      post payment_webhook_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.status).to eq(204)
      expect(response.body).to eq("")
    end

  end

  context "with a payment that changed to expired" do

    before :each do
      stub_payment_webhook_request(@payment.remote_id, "expired")
    end

    it "changes the payment status to aborted" do
      expect {
        post payment_webhook_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      }.to change {
        Apartment::Tenant.switch!(@tenant.token)
        @payment.reload
        status = @payment.status
        Apartment::Tenant.reset
        status
      }.to("aborted")

    end

    it "returns a NO CONTENT status" do
      post payment_webhook_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.status).to eq(204)
      expect(response.body).to eq("")
    end

  end

  context "with a payment that changed to failed" do

    before :each do
      stub_payment_webhook_request(@payment.remote_id, "failed")
    end

    it "changes the payment status to aborted" do
      expect {
        post payment_webhook_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      }.to change {
        Apartment::Tenant.switch!(@tenant.token)
        @payment.reload
        status = @payment.status
        Apartment::Tenant.reset
        status
      }.to("aborted")

    end

    it "returns a NO CONTENT status" do
      post payment_webhook_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.status).to eq(204)
      expect(response.body).to eq("")
    end

  end

  context "with a payment id that doesn't exist" do

    it "returns a NOT FOUND status" do
      post payment_webhook_path(@tenant.token, -1), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.status).to eq(404)
      expect(response.body).to eq("")
    end

  end

end
