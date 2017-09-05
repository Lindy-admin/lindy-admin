class Payment < ApplicationRecord
  belongs_to :registration

  enum status: {
    created: 0,
    submitted: 1,
    completed: 2,
    failed: 3
  }
end
