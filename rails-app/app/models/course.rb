class Course < ApplicationRecord
  has_many :registrations
  has_many :participants, through: :registrations, source: :person

end
