class AddTicketToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_reference :registrations, :ticket, foreign_key: true
  end
end
