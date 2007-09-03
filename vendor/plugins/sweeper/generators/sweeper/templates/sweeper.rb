class <%= class_name %>Sweeper < ActionController::Caching::Sweeper

  observe <%= class_name %>

<% actions.each do |action| -%>
  def <%= action %>(record)
    
  end

<% end -%>

end
