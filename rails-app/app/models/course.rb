class Course < ApplicationRecord
  has_many :registrations, dependent: :destroy
  has_many :participants, through: :registrations, source: :person

  validates :title, presence: true
  validates :start, presence: true
  validates :end, presence: true

  def register(person, role)
    ActiveRecord::Base.transaction do
      person.save!
      Registration.create!(person_id: person.id, course_id: self.id, role: role)
      return true
    end
    return false
  end

end
