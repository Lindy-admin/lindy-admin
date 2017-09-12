class Mailing < ApplicationRecord
  belongs_to :registration

  enum status: {
    created: 0,
    sent: 1,
    failed: 2
  }
  
end
