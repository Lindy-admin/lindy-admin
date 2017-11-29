FactoryBot.define do
  factory :ticket do
    course
    sequence :label do |n|
      "label#{n}"
    end
    price_cents 1000
  end
end
