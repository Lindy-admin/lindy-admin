require "rails_helper"
require "mollie_helper"

describe "When updating a course" do

  let(:password) { "1234567890" }
  let(:old_course_name) { "Course1Old"}
  let(:new_course_name) { "Course1New" }

  def update_course
    visit course_path(@course.id)
    click_on "Edit"
    fill_in "course_title", with: new_course_name
    click_on "Save"
  end

  context "while not logged in" do

    before(:each) do
      @course = FactoryBot.create(:course, title: old_course_name)
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
      @course = FactoryBot.create(:course, title: old_course_name)
      Apartment::Tenant.reset

      login(@user, password)
    end

    it "will update the course" do
      expect{update_course}.to change{
        Apartment::Tenant.switch!(@user.tenant.token)
        @course.reload
        title = @course.title
        Apartment::Tenant.reset
        title
      }.from(old_course_name).to(new_course_name)
    end

    it "will show the updated course" do
      update_course
      expect(page).to have_current_path( course_path(@course.id) )
      expect(page).to have_content( new_course_name )
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)
      login(@user, password)
    end

    pending "will update the course"
    pending "will show the updated course"

  end


end
