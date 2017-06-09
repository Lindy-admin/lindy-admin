module ApplicationHelper
  def role_label(value)
    return value ? "Lead" : "Follow"
  end
end
