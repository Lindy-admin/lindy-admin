module ApplicationHelper
  def role_label(value)
    return value ? "Lead" : "Follow"
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  def render_source view
    html = CodeRay.scan(render(view), :html).div(:line_numbers => :table)
    raw(html)
  end
end
