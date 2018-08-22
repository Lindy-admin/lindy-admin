require "rails_helper"
require "mollie_helper"

describe "When registering listing tags" do

  before(:each) do
    @user = FactoryBot.create(:user, role: :admin)
    @tenant = @user.tenant
    Apartment::Tenant.switch!(@tenant.token)

    @LOCATION_NIJMEGEN = "Nijmegen"
    @LOCATION_DENBOSCH = "Den Bosch"
    @LOCATION_UTRECHT = "Utrecht"

    @STYLE_LINDY = "Lindy Hop"
    @STYLE_SHAG = "Shag"
    @STYLE_BALBOA = "Balboa"

    @course1 = FactoryBot.create(:course, registration_start: DateTime.now.to_date - 2.days, registration_end: DateTime.now.to_date + 2.days)
    @course1.location_list = [@LOCATION_NIJMEGEN]
    @course1.style_list = [@STYLE_SHAG]
    @course1.save!
    @ticket1 = FactoryBot.create(:ticket, course: @course1)

    @course2 = FactoryBot.create(:course, registration_start: DateTime.now.to_date - 2.days, registration_end: DateTime.now.to_date + 2.days)
    @course2.location_list = [@LOCATION_NIJMEGEN, @LOCATION_DENBOSCH]
    @course2.style_list = [@STYLE_LINDY]
    @course2.save!
    @ticket2 = FactoryBot.create(:ticket, course: @course2)

    @course3 = FactoryBot.create(:course, registration_start: DateTime.now.to_date - 2.days, registration_end: DateTime.now.to_date + 2.days)
    @ticket3 = FactoryBot.create(:ticket, course: @course3)
    @course3.location_list = [@LOCATION_DENBOSCH]
    @course3.style_list = [@STYLE_LINDY]
    @course3.save!

    @course4 = FactoryBot.create(:course, registration_start: DateTime.now.to_date - 2.days, registration_end: DateTime.now.to_date + 2.days)
    @ticket4 = FactoryBot.create(:ticket, course: @course3)
    @course4.location_list = [@LOCATION_UTRECHT]
    @course4.style_list = [@STYLE_SHAG]
    @course4.save!

    @course5 = FactoryBot.create(:course, registration_start: DateTime.now.to_date - 2.days, registration_end: DateTime.now.to_date + 2.days)
    @ticket4 = FactoryBot.create(:ticket, course: @course3)
    @course5.location_list = [@LOCATION_DENBOSCH]
    @course5.style_list = [@STYLE_BALBOA]
    @course5.save!

    Apartment::Tenant.reset
  end

  def perform
    get api_styles @tenant.token, params: params, headers: headers
  end

  context "asking for the style tags" do

    let (:headers) do
      {
        HTTP_ACCEPT: 'application/json'
      }
    end

    let (:perform) {
      get api_styles_path @tenant.token, headers: headers
    }

    it "will show only unique values" do
      perform

      expect(response.status).to be(200)

      body = JSON.parse response.body
      expect(body).to eq(
        [@STYLE_BALBOA, @STYLE_LINDY, @STYLE_SHAG]
      )
    end

  end

  context "asking for the location tags" do

    let (:headers) do
      {
        HTTP_ACCEPT: 'application/json'
      }
    end

    let (:perform) {
      get api_locations_path @tenant.token, headers: headers
    }

    it "will show only unique values" do
      perform

      expect(response.status).to be(200)

      body = JSON.parse response.body
      expect(body).to eq(
        [@LOCATION_DENBOSCH, @LOCATION_NIJMEGEN, @LOCATION_UTRECHT]
      )
    end

  end

end
