require "rails_helper"

describe "When a registration is accepted" do

  context "while it was previously in triage status" do

    before(:each) do
      @registration = FactoryBot.create(:registration, status: :triage)
    end

    it "sends an acceptance email" do
      expect{
        @registration.update!(status: :accepted)
      }.to change{AcceptedMailingWorker.jobs.length}.by(1)
    end

    pending "notifies the admin"

    pending "logs to the audit log"

  end

  context "while it was previously in waitinglist status" do

    before(:each) do
      @registration = FactoryBot.create(:registration, status: :waitinglist)
    end

    it "sends an acceptance email" do
      expect{
        @registration.update!(status: :accepted)
      }.to change{AcceptedMailingWorker.jobs.length}.by(1)
    end

    pending "notifies the admin"

    pending "logs to the audit log"

  end

end

describe "When a registration is put onto the waitinglist", type: :request do

  context "while it was previously in triage status" do

    before(:each) do
      @registration = FactoryBot.create(:registration, status: :triage)
    end

    it "sends a waitinglist email" do
      expect{
        @registration.update!(status: :waitinglist)
      }.to change{WaitinglistMailingWorker.jobs.length}.by(1)
    end

    pending "notifies the admin"

    pending "logs to the audit log"

  end

  context "while it was previously in accepted status" do

    before(:each) do
      @registration = FactoryBot.create(:registration, status: :accepted)
    end

    it "sends a waitinglist email" do
      expect{
        @registration.update!(status: :waitinglist)
      }.to change{WaitinglistMailingWorker.jobs.length}.by(1)
    end

    pending "notifies the admin"

    pending "logs to the audit log"

  end

end
