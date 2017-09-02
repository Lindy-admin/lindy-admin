class Registration < ApplicationRecord
  belongs_to :member
  belongs_to :course
  belongs_to :ticket
end
