class Ticket < ApplicationRecord
  belongs_to :course

  monetize :price_cents, allow_nil: false

  validates :label, presence: true
end
