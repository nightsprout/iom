module GeoregionHelper
  def georegion_projects_list_subtitle
    if @filter_by_category
      pluralize(@projects.total_entries, "#{@category_name} project", "#{@category_name} projects") + " in #{@area.name.capitalize}"
    else
      "#{pluralize(@projects.total_entries, 'project', 'projects')} in #{@area.name.capitalize}"
    end
  end

end
