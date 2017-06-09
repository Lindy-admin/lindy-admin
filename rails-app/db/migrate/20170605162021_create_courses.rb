class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.date :start, null: false
      t.date :end, null: false

      t.timestamps
    end
  end
end
