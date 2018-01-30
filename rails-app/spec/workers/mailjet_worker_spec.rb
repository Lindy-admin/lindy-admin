require "rails_helper"
require "mollie_helper"

describe "MailjetWorker" do

  before(:all) do

  end

  describe "sending a mail" do

    context "succesfully" do

      let(:remote_id) {456}

      before(:each) do
        @subject = MailjetWorker.new
        @mailing = FactoryBot.create(:mailing, remote_id: nil)

        stub_request(:post, "https://api.mailjet.com/v3.1/send").
          to_return(
            status: 200,
            headers: {},
            body: {
              Messages: [
                {
                  Status: "success",
                  To: [
                    {
                      Email: @mailing.registration.member.email,
                      MessageUUID: "123",
                      MessageID: remote_id,
                      MessageHref: "https://api.mailjet.com/v3/message/#{remote_id}"
                    }
                  ]
                }
              ]
            }.to_json
          )
      end

      it "calls the Mailjet API" do
        @subject.perform(@mailing.id)
        assert_requested :post,  "https://api.mailjet.com/v3.1/send"
      end

      it "updates the Mailing status" do
        expect {
          @subject.perform(@mailing.id)
        }.to change{
          @mailing.reload
          @mailing.status
        }.from("created").to("sent")
      end

      it "updates the Mailing remote id" do
        expect {
          @subject.perform(@mailing.id)
        }.to change{
          @mailing.reload
          @mailing.remote_id
        }.from(nil).to("#{remote_id}")
      end

    end

    context "unsuccesfully" do

      let(:remote_id) {456}

      before(:each) do
        @subject = MailjetWorker.new
        @mailing = FactoryBot.create(:mailing, remote_id: nil)

        stub_request(:post, "https://api.mailjet.com/v3.1/send").
          to_return(
            status: 200,
            headers: {},
            body: {
              Messages: [
                {
                  Status: "failed",
                  To: [
                    {
                      Email: @mailing.registration.member.email,
                      MessageUUID: "123",
                      MessageID: remote_id,
                      MessageHref: "https://api.mailjet.com/v3/message/#{remote_id}"
                    }
                  ]
                }
              ]
            }.to_json
          )
      end

      it "calls the Mailjet API" do
        @subject.perform(@mailing.id)
        assert_requested :post,  "https://api.mailjet.com/v3.1/send"
      end

      it "updates the Mailing status" do
        expect {
          @subject.perform(@mailing.id)
        }.to change{
          @mailing.reload
          @mailing.status
        }.from("created").to("failed")
      end

      it "updates the Mailing remote id" do
        expect {
          @subject.perform(@mailing.id)
        }.to change{
          @mailing.reload
          @mailing.remote_id
        }.from(nil).to("#{remote_id}")
      end

    end

    context "servererror" do

      before(:each) do
        @subject = MailjetWorker.new
        @mailing = FactoryBot.create(:mailing, remote_id: nil)

        stub_request(:post, "https://api.mailjet.com/v3.1/send").
          to_return(
            status: 500,
            headers: {},
            body: {
                ErrorInfo: "Internal Server Error",
                ErrorMessage: "Ouch! Something went wrong on our side and we apologize!",
                ErrorIdentifier: "D4DF574C-0C5F-45C7-BA52-7AA8E533C3DE",
                StatusCode: 500
            }.to_json
          )
      end

      pending "should retry later"

    end

  end

end
