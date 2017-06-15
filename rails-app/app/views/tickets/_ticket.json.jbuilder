json.extract! ticket, :id, :course_id, :label, :price, :created_at, :updated_at
json.url ticket_url(ticket, format: :json)
