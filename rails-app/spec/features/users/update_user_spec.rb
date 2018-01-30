require "rails_helper"
require "mollie_helper"

describe "When updating a user" do

  let(:password) { "1234567890" }
  let(:old_email) { "old_email@test.test" }
  let(:new_email) { "new_email@test.test" }

  def update_user(user)
    visit user_path(user)
    click_on "Edit"
    fill_in "user_email", with: new_email
    click_on "Save"
  end

  before(:each) do
    @target_user = FactoryBot.create(:user, role: :admin, email: old_email)
  end

  context "while not logged in" do

    before(:each) do
      FactoryBot.create(:course)
    end

    it "will redirect the user to a login screen" do
      begin
        update_user(@target_user)
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

    it "will not update the user" do
      expect{
        begin
        update_user(@target_user)
        rescue Capybara::ElementNotFound
        end
      }.to_not change {
        @target_user.reload
        @target_user.email
      }
    end

    it "will redirect the current user" do
      begin
        update_user(@target_user)
      rescue Capybara::ElementNotFound
      end
      expect(page).to have_current_path( root_path )
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)
      login(@user, password)
    end

    it "will update the user" do
      expect{update_user(@target_user)}.to change {
        @target_user.reload
        @target_user.email
      }.from(old_email).to(new_email)
    end

    it "will show the new user" do
      update_user(@target_user)
      expect(page).to have_current_path( user_path(@target_user) )
    end

  end


end
