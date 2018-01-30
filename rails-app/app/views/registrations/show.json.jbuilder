json.extract! @registration, :id, :member, :course, :ticket, :payment
json.url registration_url(@registration, format: :json)
