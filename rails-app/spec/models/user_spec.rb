require 'rails_helper'

describe "User" do

  context "when it is created" do

    let(:password) { "password1"}

    before(:each) do
      @existingUser = FactoryBot.create(:user)
    end

    it "generates a unique tenant name" do
      newUser = User.create(email: "email1@mail.com", password: password, password_confirmation: password)
      expect(newUser.tenant).to_not eq(@existingUser.tenant)
    end

    it "validates that the tenant name is unique" do
      newUser = User.new(email: "email1@mail.com", password: password, password_confirmation: password, tenant: @existingUser.tenant)
      expect { newUser.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

  end

end
