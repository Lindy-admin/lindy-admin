json.extract! ticket, :id, :course_id, :label, :price, :created_at, :updated_at
json.url course_ticket_url(ticket.course, ticket, format: :json)
