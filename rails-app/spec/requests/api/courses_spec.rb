require "rails_helper"
require "mollie_helper"

describe "When requesting the available courses" do

  before(:each) do
    @user = FactoryBot.create(:user, role: :admin)
    @tenant = @user.tenant
  end

  context "with a course that is open for registration" do

    before(:each) do
      Apartment::Tenant.switch!(@tenant.token)
      @course = FactoryBot.create(:course, registration_start: DateTime.now.to_date - 2.days, registration_end: DateTime.now.to_date + 2.days)
      @ticket = FactoryBot.create(:ticket, course: @course)
      Apartment::Tenant.reset
    end

    let (:headers) do
      {
        HTTP_ACCEPT: 'application/json'
      }
    end

    it "will return the course" do
      get api_courses_path @tenant.token, headers: headers

      expect(response.status).to be(200)

      body = JSON.parse response.body
      expect(body.length).to eq(1)
      expect(body[0]["id"]).to eq(@course.id)
      expect(body[0]["title"]).to eq(@course.title)
    end

  end

  context "with no course that is open for registration" do

    before(:each) do
      Apartment::Tenant.switch!(@tenant.token)
      @course = FactoryBot.create(:course, registration_start: DateTime.now.to_date - 4.days, registration_end: DateTime.now.to_date - 2.days)
      @ticket = FactoryBot.create(:ticket, course: @course)
      Apartment::Tenant.reset
    end

    let (:headers) do
      {
        HTTP_ACCEPT: 'application/json'
      }
    end

    it "will return no course" do
      get api_courses_path @tenant.token, headers: headers

      expect(response.status).to be(200)

      body = JSON.parse response.body
      expect(body.length).to eq(0)
    end

  end

end
