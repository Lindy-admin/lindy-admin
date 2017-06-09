class Course < ApplicationRecord
  has_many :registrations, dependent: :destroy
  has_many :participants, through: :registrations, source: :person

  validates :title, presence: true
  validates :start, presence: true
  validates :end, presence: true

  def leads
    registrations.where(role: true).count
  end
  def follows
    registrations.where(role: false).count
  end

  def register(person, person_params, role)
    ActiveRecord::Base.transaction do
      person.update_attributes(person_params)
      person.save!
      Registration.create!(person_id: person.id, course_id: self.id, role: role)
      return true
    end
    return false
  end

end
