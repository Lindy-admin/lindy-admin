FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "email#{n}@test.test"
    end
    sequence :password do |n|
      "password#{n}"
    end
  end
end
