FactoryBot.define do
  factory :registration do
    course
    ticket
    member
    role true
    status :triage
  end
end
