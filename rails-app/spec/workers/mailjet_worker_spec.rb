require "rails_helper"
require "mollie_helper"

describe "MailjetWorker" do

  describe "sending a member mail" do

    before(:each) do
      @subject = MailjetWorker.new
      @tenant = FactoryBot.create(:user, role: :admin).tenant

      Apartment::Tenant.switch!(@tenant.token)
      @mailing = FactoryBot.create(:mailing, target: :member, label: :payment, remote_id: nil)

      Setting[:mailjet_public_api_key] = "1234567890"
      Setting[:mailjet_private_api_key] = "0987654321"
      Setting[:mailjet_sender_email_address] = "sender@test.test"
      Setting[:mailjet_sender_email_name] = "Sender name"
      Setting.save
    end

    after(:each) do
      Apartment::Tenant.reset
    end

    context "succesfully" do

      let(:remote_id) {456}

      before(:each) do

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
                      Email: Setting[:notification_email_address],
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

    context "without a template id" do

      before(:each) do
        @mailing = FactoryBot.create(:mailing, remote_id: nil, remote_template_id: nil)
      end

      it "does not call the Mailjet API" do
        @subject.perform(@mailing.id)
        assert_not_requested :post,  "https://api.mailjet.com/v3.1/send"
      end

      it "updates the Mailing status" do
        expect {
          @subject.perform(@mailing.id)
        }.to change{
          @mailing.reload
          @mailing.status
        }.from("created").to("failed")
      end

    end

    context "without mailjet settings" do

      before(:each) do
        @mailing = FactoryBot.create(:mailing, remote_id: nil, remote_template_id: nil)

        Setting[:mailjet_public_api_key] = nil
        Setting[:mailjet_private_api_key] = nil
        Setting.save
      end

      it "does not call the Mailjet API" do
        @subject.perform(@mailing.id)
        assert_not_requested :post,  "https://api.mailjet.com/v3.1/send"
      end

      it "updates the Mailing status" do
        expect {
          @subject.perform(@mailing.id)
        }.to change{
          @mailing.reload
          @mailing.status
        }.from("created").to("failed")
      end

    end

    context "servererror" do

      before(:each) do
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

  describe "sending an admin email" do

    let(:admin_email) {"admin@test.test"}

    before(:each) do
      @subject = MailjetWorker.new
      @tenant = FactoryBot.create(:user, role: :admin).tenant

      Apartment::Tenant.switch!(@tenant.token)
      @mailing = FactoryBot.create(:mailing, target: :admin, label: :payment, remote_id: nil)

      Setting[:mailjet_public_api_key] = "1234567890"
      Setting[:mailjet_private_api_key] = "0987654321"
      Setting[:mailjet_sender_email_address] = "sender@test.test"
      Setting[:mailjet_sender_email_name] = "Sender name"
      Setting[:notification_email_address] = admin_email
      Setting[:mailjet_notification_email_template_id] = 1
      Setting.save
    end

    context "succesfully" do

      let(:remote_id) {456}

      before(:each) do
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

      context "unsuccesfully" do

        let(:remote_id) {456}

        before(:each) do
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

    context "without mailjet settings" do

      before(:each) do
        Setting[:mailjet_public_api_key] = nil
        Setting[:mailjet_private_api_key] = nil
        Setting.save
      end

      it "does not call the Mailjet API" do
        @subject.perform(@mailing.id)
        assert_not_requested :post,  "https://api.mailjet.com/v3.1/send"
      end

      it "updates the Mailing status" do
        expect {
          @subject.perform(@mailing.id)
        }.to change{
          @mailing.reload
          @mailing.status
        }.from("created").to("failed")
      end

    end

    context "without a notification email address" do

      before(:each) do
        Setting[:notification_email_address] = nil
        Setting.save
      end

      it "does not call the Mailjet API" do
        @subject.perform(@mailing.id)
        assert_not_requested :post,  "https://api.mailjet.com/v3.1/send"
      end

      it "updates the Mailing status" do
        expect {
          @subject.perform(@mailing.id)
        }.to change{
          @mailing.reload
          @mailing.status
        }.from("created").to("failed")
      end

    end

    context "servererror" do

      before(:each) do
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
