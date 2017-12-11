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
    sequence :address do |n|
      "addressstreet #{n}"
    end
  end
end
