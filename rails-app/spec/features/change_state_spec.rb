require 'rails_helper'

feature "Waitinglist", type: :feature do

  scenario "An admin puts a registration from triage on the waiting list" do

    stub_request(:post, "https://api.mollie.nl/v1/payments").
    to_return(
        status: 200,
        headers:{
          "Content-Type" => "application/json; charset=utf-8"
        },
        body: {
          resource:        "payment",
          id:              "tr_7UhSN1zuXS",
          mode:            "test",
          createdDatetime: "2017-11-29T12:22:59.0Z",
          status:          "open",
          expiryPeriod:    "PT15M",
          amount:          10.00,
          description:     "My first payment",
          metadata: {
              order_id: "12345"
          },
          locale: "nl",
          profileId: "pfl_QkEhN94Ba",
          links: {
              paymentUrl:  "https://www.mollie.com/payscreen/select-method/7UhSN1zuXS",
              redirectUrl: "https://webshop.example.org/order/12345/",
              webhookUrl:  "https://webshop.example.org/payments/webhook/"
          }
      }.to_json
    )

    registration = FactoryBot.create(:registration, status: :triage)
    payment = FactoryBot.create(:payment, registration: registration)

    expect {
      visit edit_registration_path(registration)
      select "waitinglist", from: "status"
      click_button "Submit"

      expect(page).to have_content("Registration was successfully updated.")
      expect(page).to have_select("status", selected: "waitinglist")
    }.to change{registration.status}.from("triage").to("waitinglist")


  end

end
