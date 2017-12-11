FactoryBot.define do
  factory :payment do
    status 0
    sequence :remote_id do |n|
      "remote_id#{n}"
    end
    sequence :payment_url do |n|
      "payment_url#{n}"
    end
  end
end
