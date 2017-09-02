class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :registrations do |t|
      t.references :member, foreign_key: true
      t.references :course, foreign_key: true

      t.index [:member_id, :course_id], unique: true
      t.timestamps
    end
  end
end
