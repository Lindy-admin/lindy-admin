class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :registrations do |t|
      t.references :member, foreign_key: {on_delete: :cascade}
      t.references :course, foreign_key: {on_delete: :cascade}

      t.index [:member_id, :course_id], unique: true
      t.timestamps
    end
  end
end
