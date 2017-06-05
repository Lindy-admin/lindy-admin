class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :registrations do |t|
      t.references :person, foreign_key: true
      t.references :course, foreign_key: true

      t.index [:person_id, :course_id], unique: true
      t.timestamps
    end
  end
end
