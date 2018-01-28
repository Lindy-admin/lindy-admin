require "rails_helper"
require "mollie_helper"

describe "When deleting a course" do

  let(:password) { "1234567890" }

  def delete_course
    visit course_path(@course.id)
    click_on "Destroy"
  end

  context "while not logged in" do

    before(:each) do
      FactoryBot.create(:course)
    end

    it "will redirect the user to a login screen" do
      visit courses_path
      expect(page).to have_current_path( new_user_session_path )
    end

  end

  context "while logged in as an admin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :admin, password: password)

      Apartment::Tenant.switch!(@user.tenant.token)
      @course = FactoryBot.create(:course)
      Apartment::Tenant.reset

      login(@user, password)
    end

    it "will delete the course" do
      expect{delete_course}.to change {
        Apartment::Tenant.switch!(@user.tenant.token)
        count = Course.count
        Apartment::Tenant.reset
        count
      }.by(-1)
    end

    it "will redirect to the courses overview" do
      delete_course
      expect(page).to have_current_path( courses_path )
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)

      Apartment::Tenant.switch!(@user.tenant.token)
      @course = FactoryBot.create(:course)
      Apartment::Tenant.reset

      login(@user, password)
    end

    pending "will delete the course"
    pending "will show the updated course"

  end


end
