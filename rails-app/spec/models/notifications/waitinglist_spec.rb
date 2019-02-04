require "rails_helper"

describe "When a registration is put onto the waitinglist", type: :request do

  def perform
    Apartment::Tenant.switch!(@tenant_token)
    @registration.update!(status: :waitinglist)
    Apartment::Tenant.reset
  end

  def mailings_count(target)
    Apartment::Tenant.switch!(@tenant_token)
    count = Mailing.where(target: target, label: :waitinglist).count
    Apartment::Tenant.reset
    return count
  end

  def last_mailing(target)
    Apartment::Tenant.switch!(@tenant_token)
    last = Mailing.where(target: target, label: :waitinglist).last
    Apartment::Tenant.reset
    return last
  end

  context "with correct settings" do

    context "while it was previously in triage status" do

      before(:each) do
        @user = FactoryBot.create(:user, role: :admin)
        @tenant_token = @user.tenant.token

        Apartment::Tenant.switch!(@tenant_token)
        Config.create!
        @registration = FactoryBot.create(:registration, status: :triage)
        Apartment::Tenant.reset
      end

      it "sends a waitinglist email" do
        expect{
          perform
        }.to change{ mailings_count(:member) }.by(1)

        expect(MailjetWorker).to have_enqueued_sidekiq_job(@tenant_token, last_mailing(:member).id)
      end

      it "notifies the admin" do
        expect {
          perform
        }.to change{ mailings_count(:admin) }.by(1)

        expect(MailjetWorker).to have_enqueued_sidekiq_job(@tenant_token, last_mailing(:admin).id)
      end

      pending "logs to the audit log"

    end

    context "while it was previously in accepted status" do

      before(:each) do
        @user = FactoryBot.create(:user, role: :admin)
        @tenant_token = @user.tenant.token

        Apartment::Tenant.switch!(@tenant_token)
        Config.create!
        @registration = FactoryBot.create(:registration, status: :accepted)
        Apartment::Tenant.reset
      end

      it "sends a waitinglist email" do
        expect{
          perform
        }.to change{ mailings_count(:member) }.by(1)

        expect(MailjetWorker).to have_enqueued_sidekiq_job(@tenant_token, last_mailing(:member).id)
      end

      it "notifies the admin" do
        expect {
          perform
        }.to change{mailings_count(:admin)}.by(1)

        expect(MailjetWorker).to have_enqueued_sidekiq_job(@tenant_token, last_mailing(:admin).id)
      end

      pending "logs to the audit log"

    end

  end

end
