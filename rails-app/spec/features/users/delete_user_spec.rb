require "rails_helper"
require "mollie_helper"

describe "When deleting a user" do

  let(:password) { "1234567890" }

  def delete_user(user)
    visit user_path(user)
    click_on "Destroy"
  end

  before(:each) do
    @target_user = FactoryBot.create(:user, role: :admin)
  end

  context "while not logged in" do

    it "will redirect the current user to a login screen" do
      begin
        delete_user(@target_user)
      rescue Capybara::ElementNotFound
      end
      expect(page).to have_current_path( new_user_session_path )
    end

  end

  context "while logged in as an admin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :admin, password: password)
      login(@user, password)
    end

    it "will not delete the user" do
      expect{
        begin
          delete_user(@target_user)
        rescue Capybara::ElementNotFound
        end
      }.to_not change {
        User.count
      }
    end

    it "will show the users overview" do
      begin
        delete_user(@target_user)
      rescue Capybara::ElementNotFound
      end
      expect(page).to have_current_path( users_path )
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)
      login(@user, password)
    end

    it "will delete the user" do
      expect{delete_user(@target_user)}.to change {
        User.count
      }.by(-1)
    end

    it "will show the users overview" do
      delete_user(@target_user)
      expect(page).to have_current_path( users_path )
    end

  end


end
