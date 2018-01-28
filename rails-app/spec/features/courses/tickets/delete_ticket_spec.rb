require "rails_helper"
require "mollie_helper"

describe "When deleting a ticket" do

  let(:password) { "1234567890" }

  def delete_ticket
    visit course_path(@course.id)
    click_on "Remove"
  end



  context "while not logged in" do

    before(:each) do
      @course = FactoryBot.create(:course)
      @ticket = FactoryBot.create(:ticket, course: @course)
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
      @ticket = FactoryBot.create(:ticket, course: @course)
      Apartment::Tenant.reset

      login(@user, password)
    end

    it "will delete the ticket" do
      expect{delete_ticket}.to change {
        Apartment::Tenant.switch!(@user.tenant.token)
        count = Ticket.count
        Apartment::Tenant.reset
        count
      }.by(-1)
    end

    it "will redirect to the course overview" do
      delete_ticket
      expect(page).to have_current_path( course_path(@course.id) )
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)
      login(@user, password)
    end

    pending "will delete the ticket"
    pending "will redirect to the course overview"

  end


end
