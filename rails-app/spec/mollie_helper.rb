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

def stub_payment_webhook_request(remote_id, status)
  stub_request(:get, "https://api.mollie.nl/v1/payments/#{remote_id}").
     to_return(
       status: 200,
       headers: {},
       body: {
            "resource": "payment",
            "id": remote_id,
            "mode": "test",
            "createdDatetime": "2018-02-16T14:34:30.0Z",
            "status": status,
            "paidDatetime": "2014-09-05T14:37:35.0Z",
            "amount": "35.07",
            "description": "Order 33",
            "method": "ideal",
            "metadata": {
                "order_id": "33"
            },
            "details": {
                "consumerName": "Hr E G H K\u00fcppers en\/of MW M.J. K\u00fcppers-Veeneman",
                "consumerAccount": "NL53INGB0618365937",
                "consumerBic": "INGBNL2A"
            },
            "locale": "nl",
            "profileId": "pfl_QkEhN94Ba",
            "links": {
                "webhookUrl": "https://webshop.example.org/payments/webhook",
                "redirectUrl": "https://webshop.example.org/order/33/"
            }
        }.to_json
     )
end
