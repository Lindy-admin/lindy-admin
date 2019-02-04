FactoryBot.define do
  factory :registration do
    course
    ticket
    member
    role :lead
    status :triage
  end
end
