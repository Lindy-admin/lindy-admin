class Registration < ApplicationRecord
  belongs_to :member
  belongs_to :course
  belongs_to :ticket
  has_one :payment, dependent: :destroy
  has_many :mailings, dependent: :destroy_all
end
