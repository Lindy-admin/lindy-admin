require "rails_helper"
require "mollie_helper"

describe "When requesting a payments status" do

  before(:each) {
    stub_payment_creation_request

    @user = FactoryBot.create(:user, role: :admin)
    @tenant = @user.tenant
    Apartment::Tenant.switch!(@tenant.token)
    @registration = FactoryBot.create(:registration)
    Apartment::Tenant.reset
  }

  context "given the payment is payed" do

    before(:each) {
      Apartment::Tenant.switch!(@tenant.token)
      @payment = FactoryBot.create(:payment, registration: @registration)
      @payment.update!(status: :paid)
      Apartment::Tenant.reset
    }

    it "returns an OK status" do
      get payment_status_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.status).to eq(200)
    end

    it "returns the payment status in the body" do
      get payment_status_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.body).to eq({id: @payment.id, status: "paid"}.to_json)
    end

  end

  context "given the payment is unpayed" do

    before(:each) {
      Apartment::Tenant.switch!(@tenant.token)
      @payment = FactoryBot.create(:payment, registration: @registration)
      @payment.update!(status: :submitted)
      Apartment::Tenant.reset
    }

    it "returns an OK status" do
       get payment_status_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.status).to eq(200)
    end

    it "returns the payment status in the body" do
      get payment_status_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.body).to eq({id: @payment.id, status: "submitted"}.to_json)
    end

  end

  context "given the payment has failed" do

    before(:each) {
      Apartment::Tenant.switch!(@tenant.token)
      @payment = FactoryBot.create(:payment, registration: @registration)
      @payment.update!(status: :aborted)
      Apartment::Tenant.reset
    }

    it "returns an OK status" do
      get payment_status_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.status).to eq(200)
    end

    it "returns the payment status in the body" do
      get payment_status_path(@tenant.token, @payment.id), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.body).to eq({id: @payment.id, status: "aborted"}.to_json)
    end

  end

  context "given the payment doesn't exist" do

    it "returns a NOT FOUND status" do
      get payment_status_path(@tenant.token, -1), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.status).to eq(404)
    end

    it "returns an empty body" do
      get payment_status_path(@tenant.token, -1), headers: { HTTP_ACCEPT: "application/json" }
      expect(response.body).to eq("")
    end

  end

end
