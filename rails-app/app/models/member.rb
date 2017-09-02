class Member < ApplicationRecord
  has_many :registrations, dependent: :destroy
  has_many :courses, through: :registrations

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true
end
