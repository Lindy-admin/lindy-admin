class CoursesHaveARoleSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :roles, :int, null: false, default: 1
  end
end
