require "rails_helper"

describe "When a registration is accepted" do

  context "while it was previously in triage status" do

    pending "sends a payment email"

    pending "notifies the admin"

  end

  context "while it was previously in waitinglist status" do

    pending "sends a payment email"

    pending "notifies the admin"

  end

end

describe "When a registration is put onto the waitinglist", type: :request do

  context "while it was previously in triage status" do

    pending "sends a waitinglist email"

    pending "notifies the admin"

    pending "logs to the audit log"

  end

  context "while it was previously in accepted status" do

    pending "sends a waitinglist email"

    pending "notifies the admin"

    pending "logs to the audit log"

  end

end
