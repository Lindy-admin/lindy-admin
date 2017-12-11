def stub_payment_creation_request
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
