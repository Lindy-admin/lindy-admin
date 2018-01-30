require "rails_helper"
require "mollie_helper"

describe "When creating a course" do

  let(:password) { "1234567890" }
  let(:course_name) { "Course1" }

  def create_course
    visit courses_path
    click_on "New Course"
    fill_in "course_title", with: course_name
    click_on "Save"
  end

  context "while not logged in" do

    it "will redirect the user to a login screen" do
      visit courses_path
      expect(page).to have_current_path( new_user_session_path )
    end

  end

  context "while logged in as an admin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :admin, password: password)
      login_as(@user, :scope => :user)
    end

    it "will create the course" do
      expect{create_course}.to change {
        Apartment::Tenant.switch!(@user.tenant.token)
        count = Course.count
        Apartment::Tenant.reset
        count
      }.by(1)
    end

    it "will show the created course" do
      create_course

      Apartment::Tenant.switch!(@user.tenant.token)
      expect(page).to have_current_path( course_path(Course.last.id) )
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)
      login_as(@user, :scope => :user)
    end

    pending "will create the course"
    # do
    #   expect{create_course}.to change {
    #     Course.count
    #   }.by(1)
    # end

    pending "will show the created course"
    # do
    #   create_course
    #   expect(page).to have_current_path( course_path(Course.last.id) )
    # end

  end


end
