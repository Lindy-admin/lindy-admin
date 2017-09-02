class Course < ApplicationRecord
  has_many :registrations, dependent: :destroy
  has_many :participants, through: :registrations, source: :member
  has_many :tickets, dependent: :destroy

  validates :title, presence: true
  validates :start, presence: true
  validates :end, presence: true

  def leads
    registrations.where(role: true).count
  end
  def follows
    registrations.where(role: false).count
  end

  def register(member, member_params, role, ticket)
    ActiveRecord::Base.transaction do
      member.update_attributes(member_params)
      member.save!
      Registration.create!(member_id: member.id, course_id: self.id, role: role, ticket: ticket)
      return true
    end
    return false
  end

end
