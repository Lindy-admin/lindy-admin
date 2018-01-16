require 'rails_helper'
require "mollie_helper"

feature "Waitinglist" do

  let(:password) { "1234567890" }

  before(:each) do
    stub_payment_creation_request
  end

  describe "A user puts a registration from triage on the waiting list" do

    context "while logged in as an admin" do

      before(:each) do
        @user = FactoryBot.create(:user, role: :admin, password: password)
      end

      it "changes the status from triage to waitinglist" do

        registration = FactoryBot.create(:registration, status: :triage)
        payment = FactoryBot.create(:payment, registration: registration)

        expect {
          login(@user)
          visit registration_path(registration)
          click_on "Waitinglist"

          expect(page).to have_current_path( registration_path(registration) )
        }.to change{
          registration.reload
          registration.status
        }.from("triage").to("waitinglist")

      end

    end

    context "while logged in as a superadmin" do

      before(:each) do
        @user = FactoryBot.create(:user, role: :superadmin, password: password)
      end

      it "changes the status from triage to waitinglist" do

        registration = FactoryBot.create(:registration, status: :triage)
        payment = FactoryBot.create(:payment, registration: registration)

        expect {
          login(@user)
          visit registration_path(registration)
          click_on "Waitinglist"

          expect(page).to have_current_path( registration_path(registration) )
        }.to change{
          registration.reload
          registration.status
        }.from("triage").to("waitinglist")

      end

    end

  end

end
