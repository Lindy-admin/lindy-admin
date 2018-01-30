require "rails_helper"
require "mollie_helper"

describe "When creating a user" do

  let(:password) { "1234567890" }
  let(:user_email) { "TestUserName@test.test" }

  def create_user
    visit user_root_path
    click_on "New User"

    fill_in "user_email", with: user_email
    fill_in "user_password", with: password
    fill_in "user_password_confirmation", with: password
    choose "user[role]", option: "admin"

    click_on "Save"
  end

  context "while not logged in" do

    it "will redirect the current user to a login screen" do
      visit user_root_path
      expect(page).to have_current_path( new_user_session_path )
    end

  end

  context "while logged in as an admin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :admin, password: password)
      login_as(@user, :scope => :user)
    end

    it "will not create the user" do
      expect{
        begin
          create_user
        rescue Capybara::ElementNotFound
        end
      }.to_not change {
        User.count
      }
    end

    it "will redirect the current user" do
      begin
        visit user_root_path
      rescue Capybara::ElementNotFound
      end
      expect(page).to have_current_path( root_path )
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)
      login_as(@user, :scope => :user)
    end

    it "will create the user" do
      expect{create_user}.to change {
        User.count
      }.by(1)
    end

    it "will show the created user" do
       create_user
       expect(page).to have_current_path( user_path(User.last.id) )
    end

  end


end
