require "rails_helper"

describe "When registering for a course", type: :request do

  before(:all) do

    @course = FactoryBot.create(:course)
    @ticket = FactoryBot.create(:ticket, course: @course)

  end

  before(:each) do
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
  end

  context "while providing the correct input" do

    let (:params) do
      {
        firstname: "firstname",
        lastname: "lastname",
        course: @course.id,
        ticket: @ticket.id,
        role: 1,
        email: "test@email.com"
      }
    end

    it "will create a new registration" do
      expect {
        post registrations_path, params: params
      }.to change{Registration.count}.by(1)
    end

    it "will create a payment for the registration" do
      expect {
        post registrations_path, params: params
      }.to change{Payment.count}.by(1)
    end

    pending "will send an email with payment instructions"

  end

end
