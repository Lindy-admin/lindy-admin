require "rails_helper"
require "mollie_helper"

describe "When registering for a course" do

  before(:each) do
    @user = FactoryBot.create(:user, role: :admin)
    @tenant = @user.tenant
    Apartment::Tenant.switch!(@tenant.token)

    Setting.mailjet_sender_email_address = "some@email.com"
    Setting.mailjet_sender_email_name = "some_email_name"
    Setting.mailjet_paid_template_id = 1
    Setting.save

    @course = FactoryBot.create(:course)
    @ticket = FactoryBot.create(:ticket, course: @course)
    Apartment::Tenant.reset

    stub_payment_creation_request
  end

  context "while providing the correct input" do

    let (:params) do
      {
        firstname: "firstname",
        lastname: "lastname",
        course: @course.id,
        ticket: @ticket.id,
        role: 1,
        email: "test@email.com",
        additional: {
          extra1: "Some note",
          extra2: true,
          extra3: 12
        }
      }
    end

    let (:headers) do
      {
        HTTP_ACCEPT: 'application/json'
      }
    end

    it "will create a new Registration" do
      expect {
        post api_register_path @tenant.token, params: params, headers: headers
      }.to change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Registration.count
        Apartment::Tenant.reset
        count
      }.by(1)
    end

    it "will put the Registration in the triage status" do
      post api_register_path @tenant.token, params: params, headers: headers

      Apartment::Tenant.switch!(@tenant.token)
      registration = Registration.last
      Apartment::Tenant.reset
      expect(registration.status).to eq("triage")
    end

    it "will save additional properties with the Registration" do
      post api_register_path @tenant.token, params: params, headers: headers

      Apartment::Tenant.switch!(@tenant.token)
      registration = Registration.last
      Apartment::Tenant.reset
      expect(registration.additional).to eq({
        "extra1" => params[:additional][:extra1].to_s,
        "extra2" => params[:additional][:extra2].to_s,
        "extra3" => params[:additional][:extra3].to_s
      })
    end

    it "will create a Payment for the Registration" do
      expect {
        post api_register_path @tenant.token, params: params, headers: headers
      }.to change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Registration.count
        Apartment::Tenant.reset
        count
      }.by(1)
    end

    it "will return a CREATED status and the registration" do
      post api_register_path @tenant.token, params: params, headers: headers

      expect(response.status).to be(201)
      expect(response).to render_template(:register)
    end

    pending "logs to the audit log"

  end

  context "while providing an invalid email" do

    let (:params) do
      {
        firstname: "firstname",
        lastname: "lastname",
        course: @course.id,
        ticket: @ticket.id,
        role: 1,
        email: "test_email.com",
        additional: {
          extra1: "Some note",
          extra2: true,
          extra3: 12
        }
      }
    end

    let (:headers) do
      {
        HTTP_ACCEPT: 'application/json'
      }
    end

    it "will not create a new Registration" do
      expect {
        post api_register_path @tenant.token, params: params, headers: headers
      }.to_not change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Registration.count
        Apartment::Tenant.reset
        count
      }
    end

    it "will return an UNPROCESSABLE ENTITY status" do
      post api_register_path @tenant.token, params: params, headers: headers

      expect(response.status).to be(422)
    end

    pending "logs to the audit log"

  end

  context "while there is an already existing registration" do

    let (:params) do
      {
        firstname: "firstname",
        lastname: "lastname",
        course: @course.id,
        ticket: @ticket.id,
        role: 1,
        email: "test@email.com"
      }
    end

    let (:headers) do
      {
        HTTP_ACCEPT: 'application/json'
      }
    end

    before(:each) do
      post api_register_path @tenant.token, params: params, headers: headers
    end

    it "will not create a new Registration" do
      expect {
        post api_register_path @tenant.token, params: params, headers: headers
      }.to_not change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Registration.count
        Apartment::Tenant.reset
        count
      }
    end

    it "will not change the status of the existing registration" do
      Apartment::Tenant.switch!(@tenant.token)
      registration = Registration.last
      Apartment::Tenant.reset

      expect {
        post api_register_path @tenant.token, params: params, headers: headers
      }.to_not change{
        Apartment::Tenant.switch!(@tenant.token)
        status = registration.status
        Apartment::Tenant.reset
        status
      }
    end

    it "will not create a new Payment for the Registration" do
      expect {
        post api_register_path @tenant.token, params: params, headers: headers
      }.to_not change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Registration.count
        Apartment::Tenant.reset
        count
      }
    end

    it "will return an CONFLICT status and the registration" do
      post api_register_path @tenant.token, params: params, headers: headers
      expect(response.status).to be(409)
      expect(response).to render_template(:register)
    end

  end

end
