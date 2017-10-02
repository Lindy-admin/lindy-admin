json.extract! course, :id, :title, :description, :registration_start, :registration_end, :created_at, :updated_at, :tickets
json.url course_url(course, format: :json)
