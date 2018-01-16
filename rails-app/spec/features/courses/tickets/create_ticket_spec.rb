require "rails_helper"
require "mollie_helper"

describe "When creating a ticket" do

  let(:password) { "1234567890" }
  let(:ticket_label) { "TicketLabel1" }
  let(:ticket_price) { "88.44" }

  before(:each) do
    @course = FactoryBot.create(:course)
  end

  def create_ticket
    visit course_path(@course.id)
    click_on "Add Ticket"
    fill_in "ticket_label", with: ticket_label
    fill_in "ticket_price", with: ticket_price
    click_on "Save"
  end

  context "while not logged in" do

    it "will redirect the user to a login screen" do
      visit course_path(@course.id)
      expect(page).to have_current_path( new_user_session_path )
    end

  end

  context "while logged in as an admin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :admin, password: password)
      login(@user)
    end

    it "will create the ticket" do
      expect{create_ticket}.to change {
        Ticket.count
      }.by(1)
    end

    it "will show the created ticket" do
      create_ticket
      expect(page).to have_current_path( course_path(Course.last.id) )
      expect(page).to have_content(ticket_label)
      expect(page).to have_content(ticket_price)
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)
      login(@user)
    end

    it "will create the ticket" do
      expect{create_ticket}.to change {
        Ticket.count
      }.by(1)
    end

    it "will show the created ticket" do
      create_ticket
      expect(page).to have_current_path( course_path(Course.last.id) )
      expect(page).to have_content(ticket_label)
      expect(page).to have_content(ticket_price)
    end

  end


end
