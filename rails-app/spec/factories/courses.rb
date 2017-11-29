FactoryBot.define do
  factory :course do
    sequence :title do |n|
      "title#{n}"
    end
    sequence :description do |n|
      "description#{n}"
    end
    registration_start { DateTime.now.to_date }
    registration_end { DateTime.now.to_date }
  end
end
