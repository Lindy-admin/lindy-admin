FactoryBot.define do
  factory :member do
    sequence :firstname do |n|
      "firstname#{n}"
    end
    sequence :lastname do |n|
      "lastname#{n}"
    end
    sequence :email do |n|
      "email#{n}@example.test"
    end
  end
end
