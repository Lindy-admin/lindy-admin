FactoryBot.define do
  factory :mailing do
    registration
    remote_template_id 1
    label :payment
    target :member
    status :created
  end
end
