require "rails_helper"
require "mollie_helper"

describe "When configuring Mollie" do

  let(:password) { "1234567890" }

  def update_mollie_settings
    visit settings_path
    fill_in "mollie_api_key", with: mollie_api_key
    fill_in "mollie_redirect_url", with: mollie_redirect_url
    click_on "Save"
  end

  before(:each) do
    Setting.mollie_api_key = "0987654321"
    Setting.mollie_redirect_url = "http://redirect.me"
  end

  context "while logged in as an admin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :admin, password: password)
      login_as(@user, :scope => :user)
    end

    context "with valid input" do

      let(:mollie_api_key){"1234567890"}
      let(:mollie_redirect_url){"http://redirect.me/"}

      it "will update the api key" do
        expect{update_mollie_settings}.to change {
          Apartment::Tenant.switch!(@user.tenant.token)
          key = Setting.mollie_api_key
          Apartment::Tenant.reset
          key
        }.to(mollie_api_key)
      end

      it "will update the redirect url" do
        expect{update_mollie_settings}.to change {
          Apartment::Tenant.switch!(@user.tenant.token)
          url = Setting.mollie_redirect_url
          Apartment::Tenant.reset
          url
        }.to(mollie_redirect_url)
      end

    end

    context "with an empty string as input" do

      let(:mollie_api_key){""}
      let(:mollie_redirect_url){""}

      it "will empty the api key" do
        expect{update_mollie_settings}.to change {
          Apartment::Tenant.switch!(@user.tenant.token)
          key = Setting.mollie_api_key
          Apartment::Tenant.reset
          key
        }.to(mollie_api_key)
      end

      it "will empty the redirect url" do
        expect{update_mollie_settings}.to change {
          Apartment::Tenant.switch!(@user.tenant.token)
          url = Setting.mollie_redirect_url
          Apartment::Tenant.reset
          url
        }.to(mollie_redirect_url)
      end

    end

    context "with an invalid redirect url" do

      let(:mollie_api_key){"1234567890"}
      let(:mollie_redirect_url){"not a url"}

      it "will update the api key" do
        expect{update_mollie_settings}.to change {
          Apartment::Tenant.switch!(@user.tenant.token)
          key = Setting.mollie_api_key
          Apartment::Tenant.reset
          key
        }.to(mollie_api_key)
      end

      it "will not update the redirect url" do
        expect{update_mollie_settings}.to_not change {
          Apartment::Tenant.switch!(@user.tenant.token)
          url = Setting.mollie_redirect_url
          Apartment::Tenant.reset
          url
        }
      end

      pending "will show an error message"

    end

  end

end
