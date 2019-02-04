require "rails_helper"
require "mollie_helper"

describe "When registering for a course" do

  before(:each) do
    @user = FactoryBot.create(:user, role: :admin)
    @tenant = @user.tenant
    Apartment::Tenant.switch!(@tenant.token)

    @config = Config.new
    @config.mailjet_sender_email_address = "some@email.com"
    @config.mailjet_sender_email_name = "some_email_name"
    @config.mailjet_paid_template_id = 1
    @config.save!

    @course = FactoryBot.create(:course)
    @ticket = FactoryBot.create(:ticket, course: @course)
    Apartment::Tenant.reset

    stub_payment_creation_request
  end

  def perform
    post api_register_path @tenant.token, params: params, headers: headers
  end

  context "while providing the correct input" do

    let (:params) do
      {
        firstname: "firstname",
        lastname: "lastname",
        course: @course.id,
        ticket: @ticket.id,
        role: :lead,
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
        perform
      }.to change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Registration.count
        Apartment::Tenant.reset
        count
      }.by(1)
    end

    it "will put the Registration in the triage status" do
      perform

      Apartment::Tenant.switch!(@tenant.token)
      registration = Registration.last
      Apartment::Tenant.reset
      expect(registration.status).to eq("triage")
    end

    it "will save additional properties with the Registration" do
      perform

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
        perform
      }.to change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Registration.count
        Apartment::Tenant.reset
        count
      }.by(1)
    end

    it "will queue a Payment for the Registration" do
      expect {
        perform
      }.to change(PaymentWorker.jobs, :size).by(1)

      Apartment::Tenant.switch!(@tenant.token)
      payment = Payment.last
      Apartment::Tenant.reset

      expect(PaymentWorker).to have_enqueued_sidekiq_job(
        @tenant.token,
        payment.id,
        payment_webhook_url(
          @tenant.token,
          payment.id,
          host: Rails.application.config.webhook_hostname
        )
      )
    end

    it "will create Mailings for the Registration" do
      expect {
        perform
      }.to change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Mailing.count
        Apartment::Tenant.reset
        count
      }.by(2)

      Apartment::Tenant.switch!(@tenant.token)
      mailing_targets = Mailing.all.map{|mailing| mailing.target}
      Apartment::Tenant.reset
      expect(mailing_targets).to eq(["admin", "member"])
    end

    it "will queue Mailings for the registration" do
      expect {
        perform
      }.to change(MailjetWorker.jobs, :size).by(2)

      Apartment::Tenant.switch!(@tenant.token)
      mailings = Mailing.where(registration: Registration.last)
      mailings.each do |mailing|
        expect(MailjetWorker).to have_enqueued_sidekiq_job(@tenant.token, mailing.id)
      end
      Apartment::Tenant.reset
    end

    it "will return a CREATED status and the registration" do
      perform

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
        role: :lead,
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
        perform
      }.to_not change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Registration.count
        Apartment::Tenant.reset
        count
      }
    end

    it "will return an UNPROCESSABLE ENTITY status" do
      perform

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
        role: :lead,
        email: "test@email.com"
      }
    end

    let (:headers) do
      {
        HTTP_ACCEPT: 'application/json'
      }
    end

    before(:each) do
      perform
    end

    it "will not create a new Registration" do
      expect {
        perform
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
        perform
      }.to_not change{
        Apartment::Tenant.switch!(@tenant.token)
        status = registration.status
        Apartment::Tenant.reset
        status
      }
    end

    it "will not create a new Payment for the Registration" do
      expect {
        perform
      }.to_not change{
        Apartment::Tenant.switch!(@tenant.token)
        count = Registration.count
        Apartment::Tenant.reset
        count
      }
    end

    it "will return an CONFLICT status and the registration" do
      perform
      expect(response.status).to be(409)
      expect(response).to render_template(:register)
    end

  end

end
