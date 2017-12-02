class Registration < ApplicationRecord
  belongs_to :member
  belongs_to :course
  belongs_to :ticket
  has_one :payment, dependent: :destroy
  has_many :mailings, dependent: :destroy

  enum status: {
    created: 0,
    triage: 1,
    waitinglist: 2,
    accepted: 3
  }
end
