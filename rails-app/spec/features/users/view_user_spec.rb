require "rails_helper"
require "mollie_helper"

describe "When viewing a user" do

  let(:password) { "1234567890" }
  let(:user_email) { "TestUserName@test.test" }

  context "while logged in as an admin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :admin, password: password)
      login_as(@user, :scope => :user)
    end

    it "will not show the users view link" do
      visit root_url
      expect(page).not_to have_link("Users")
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)
      login_as(@user, :scope => :user)
    end

    it "will show the users view link" do
      visit root_url
      click_on "Users"
      expect(page).to have_current_path( user_root_path )
    end


  end


end
