json.extract! member, :id, :firstname, :lastname, :email, :address, :created_at, :updated_at
json.url member_url(member, format: :json)
