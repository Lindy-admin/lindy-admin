module ApplicationHelper
  def role_label(value)
    return value ? "Lead" : "Follow"
  end

  def payment_status_label(value)
    case value
    when 0
      return "created"
    when 1
      return "submitted"
    when 2
      return "completed"
    when 3
      return "failed"
    else
      return "unknown"
    end
  end


  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
end
