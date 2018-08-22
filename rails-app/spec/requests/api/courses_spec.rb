require "rails_helper"
require "mollie_helper"

describe "When requesting the available courses" do

  before(:each) do
    @user = FactoryBot.create(:user, role: :admin)
    @tenant = @user.tenant
  end

  context "with courses that are open for registration" do

    before(:each) do
      before(:each) do
        Apartment::Tenant.switch!(@tenant.token)

        @LOCATION_NIJMEGEN = "Nijmegen"
        @LOCATION_DENBOSCH = "Den Bosch"

        @STYLE_LINDY = "Lindy Hop"
        @STYLE_SHAG = "Collegiate Shag"

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
        Apartment::Tenant.reset

        @course3 = FactoryBot.create(:course, registration_start: DateTime.now.to_date - 2.days, registration_end: DateTime.now.to_date + 2.days)
        @ticket3 = FactoryBot.create(:ticket, course: @course3)
        @course3.location_list = [@LOCATION_DENBOSCH]
        @course3.style_list = [@STYLE_LINDY, @STYLE_SHAG]
        @course3.save!
        Apartment::Tenant.reset
      end
    end

    let (:headers) do
      {
        HTTP_ACCEPT: 'application/json'
      }
    end

    context "without a filter"

      let get_courses {
        get api_courses_path @tenant.token, headers: headers
      }

      it "will return all the courses" do
        get_courses
        expect(response.status).to be(200)

        body = JSON.parse response.body
        expect(body.length).to eq(3)
        expect(body[0]["id"]).to eq(@course1.id)
        expect(body[0]["title"]).to eq(@course1.title)
        expect(body[1]["id"]).to eq(@course2.id)
        expect(body[1]["title"]).to eq(@course2.title)
        expect(body[2]["id"]).to eq(@course3.id)
        expect(body[2]["title"]).to eq(@course3.title)
      end

    end

    context "with a location filter"

      let get_courses {
        get api_courses_path @tenant.token, headers: headers, params: {location: @LOCATION_NIJMEGEN}
      }

      it "will return the courses only for that location" do
        get_courses
        expect(response.status).to be(200)

        body = JSON.parse response.body
        expect(body.length).to eq(2)
        expect(body[0]["id"]).to eq(@course1.id)
        expect(body[0]["title"]).to eq(@course1.title)

        expect(body[1]["id"]).to eq(@course2.id)
        expect(body[1]["title"]).to eq(@course2.title)
      end

    end

    context "with a style filter"

      let get_courses {
        get api_courses_path @tenant.token, headers: headers, params: {style: @STYLE_SHAG}
      }

      it "will return the courses only for that location" do
        get_courses
        expect(response.status).to be(200)

        body = JSON.parse response.body
        expect(body.length).to eq(2)
        expect(body[0]["id"]).to eq(@course1.id)
        expect(body[0]["title"]).to eq(@course1.title)

        expect(body[1]["id"]).to eq(@course3.id)
        expect(body[1]["title"]).to eq(@course3.title)
      end

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
