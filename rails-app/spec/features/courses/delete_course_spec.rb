require "rails_helper"
require "mollie_helper"

describe "When updating a course" do

  let(:password) { "1234567890" }
  let(:old_course_name) { "Course1Old"}
  let(:new_course_name) { "Course1New" }

  def delete_course
    visit course_path(Course.last.id)
    click_on "Destroy"
  end

  before(:each) do
    FactoryBot.create(:course, title: old_course_name)
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
      login(@user)
    end

    it "will delete the course" do
      expect{delete_course}.to change {
        Course.count
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
      login(@user)
    end

    it "will delete the course" do
      expect{delete_course}.to change {
        Course.count
      }.by(-1)
    end

    it "will show the updated course" do
      delete_course
      expect(page).to have_current_path( courses_path )
    end

  end


end
