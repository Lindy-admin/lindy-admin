class Course < ApplicationRecord
  has_many :registrations
  has_many :participants, through: :registrations, source: :person

  validates :title, presence: true
  validates :start, presence: true
  validates :end, presence: true

  def register(person)
    ActiveRecord::Base.transaction do
      person.save!
      participants << person
      save!
      return true
    end
    return false
  end

end
