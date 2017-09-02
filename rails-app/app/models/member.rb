class Member < ApplicationRecord
  has_many :registrations, dependent: :destroy
  has_many :courses, through: :registrations

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true

  def self.to_csv(members, options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      members.each do |member|
        csv << member.attributes.values_at(*column_names)
      end
    end
  end
end
