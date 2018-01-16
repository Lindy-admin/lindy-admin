require "rails_helper"
require "mollie_helper"

describe "When updating a ticket" do

  let(:password) { "1234567890" }
  let(:ticket_label_old) { "TicketLabelOld" }
  let(:ticket_label_new) { "TicketLabelNew" }
  let(:ticket_price_old) { "88.44" }
  let(:ticket_price_new) { "44.88" }

  def update_ticket
    visit edit_course_ticket_path(@ticket.course.id, @ticket.id)
    fill_in "ticket_label", with: ticket_label_new
    fill_in "ticket_price", with: ticket_price_new
    click_on "Save"
  end

  before(:each) do
    @ticket = FactoryBot.create(:ticket, label: ticket_label_old, price: ticket_price_old)
  end

  context "while not logged in" do

    it "will redirect the user to a login screen" do
      visit edit_course_ticket_path(@ticket.course.id, @ticket.id)
      expect(page).to have_current_path( new_user_session_path )
    end

  end

  context "while logged in as an admin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :admin, password: password)
      login(@user)
    end

    it "will update the ticket" do
      expect{update_ticket}.to change{
        @ticket.reload
        @ticket.label
      }.from(ticket_label_old).to(ticket_label_new)
    end

    it "will show the updated ticket" do
      update_ticket
      expect(page).to have_current_path( course_path(@ticket.course.id) )
      expect(page).to have_content( ticket_label_new )
      expect(page).to have_content( ticket_price_new )
    end

  end

  context "while logged in as a superadmin" do

    before(:each) do
      @user = FactoryBot.create(:user, role: :superadmin, password: password)
      login(@user)
    end

    it "will update the ticket" do
      expect{update_ticket}.to change{
        @ticket.reload
        @ticket.label
      }.from(ticket_label_old).to(ticket_label_new)
    end

    it "will show the updated ticket" do
      update_ticket
      expect(page).to have_current_path( course_path(@ticket.course.id) )
      expect(page).to have_content( ticket_label_new )
      expect(page).to have_content( ticket_price_new )
    end

  end


end
