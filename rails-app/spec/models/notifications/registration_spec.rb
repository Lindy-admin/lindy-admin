require "rails_helper"
require "mollie_helper"

describe "When a member registers for a course" do

  def perform(member, member_params, role, ticket, additional_params)
    Apartment::Tenant.switch!(@tenant_token)
    @course.register(member, member_params, role, ticket, additional_params)
    Apartment::Tenant.reset
  end

  def mailings_count(target)
    Apartment::Tenant.switch!(@tenant_token)
    count = Mailing.where(target: target, label: :registration).count
    Apartment::Tenant.reset
    return count
  end

  def last_mailing(target)
    Apartment::Tenant.switch!(@tenant_token)
    last = Mailing.where(target: target, label: :registration).last
    Apartment::Tenant.reset
    return last
  end

  context "with correct settings" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :admin)
      @tenant_token = @user.tenant.token

      Apartment::Tenant.switch!(@tenant_token)
      @member = FactoryBot.create(:member)
      @course = FactoryBot.create(:course)
      @ticket = FactoryBot.create(:ticket, course: @course)
      Apartment::Tenant.reset

      stub_payment_creation_request
    end

    it "will send an email confirmation" do
      expect {
        perform(@member, {}, true, @ticket, {})
      }.to change{ mailings_count(:member) }.by(1)

      expect(MailjetWorker).to have_enqueued_sidekiq_job( @tenant_token, last_mailing(:member).id )
    end

    it "notifies the admin" do
      expect {
        perform(@member, {}, true, @ticket, {})
      }.to change{ mailings_count(:admin) }.by(1)

      expect(MailjetWorker).to have_enqueued_sidekiq_job( @tenant_token, last_mailing(:admin).id )
    end


    pending "logs to the audit log"

  end

end
