require 'rails_helper'

describe "Tenant" do

  context "when it is created" do

    let(:password) { "password1"}

    before(:each) do
      @existingUser = FactoryBot.create(:user)
    end

    context "and is not assigned a Tenant" do

      it "generates a tenant" do
        newUser = User.create!(email: "email1@mail.com", password: password, password_confirmation: password)
        expect(newUser.tenant).to_not be(nil)
        expect(newUser.tenant_id).to_not eq(@existingUser.tenant_id)
      end

    end

    context "and is assigned a Tenant" do

      it "belongs to that Tenant" do
        tenant = FactoryBot.create(:tenant)
        newUser = User.create!(email: "email1@mail.com", password: password, password_confirmation: password, tenant: tenant)
        expect(newUser.tenant).to_not be(nil)
        expect(newUser.tenant_id).to eq(tenant.id)
      end

    end

  end

end

describe "SuperAdmin" do

  context "when it is created" do

    let(:password) { "password1"}

    before(:each) do
      @existingUser = FactoryBot.create(:user)
    end

    it "does not belong to a Tenant" do
      newUser = User.create!(email: "email1@mail.com", password: password, password_confirmation: password, role: "superadmin")
      expect(newUser.tenant).to be(nil)
    end

  end

end
