FactoryBot.define do
  factory :tenant do
    sequence :label do |n|
      "label#{n}"
    end
  end
end
