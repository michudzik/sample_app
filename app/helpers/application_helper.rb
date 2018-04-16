module ApplicationHelper

  # Returns the full-title on per-page basis              # Documentation comment
  def full_title(page_title = '')                         # Method definition with optional parameter
    base_title = "Ruby on Rails Tutorial Sample App"      # Variable assignment
    if page_title.empty?                                  # Control flow - boolean test
      base_title                                          # Implicit return
    else
      page_title + ' | ' + base_title                     # String concatenation
    end
  end
end
