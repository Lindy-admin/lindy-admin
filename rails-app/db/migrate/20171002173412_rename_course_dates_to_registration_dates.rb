class RenameCourseDatesToRegistrationDates < ActiveRecord::Migration[5.0]
  def change
    rename_column :courses, :start, :registration_start
    rename_column :courses, :end, :registration_end
  end
end
