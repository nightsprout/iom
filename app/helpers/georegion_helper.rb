module GeoregionHelper
  def georegion_projects_list_subtitle
    if @filter_by_category
      pluralize(@projects.total_entries, "#{@category_name} active project", "#{@category_name} active projects") + " in #{@area.name.capitalize}"
    else
      "#{pluralize(@projects.total_entries, 'active project', 'active projects')} in #{@area.name.capitalize}"
    end
  end

end
