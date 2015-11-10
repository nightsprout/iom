module GeoregionHelper
  def georegion_projects_list_subtitle
    if @filter_by_category
      pluralize(@georegion_projects_count, "#{@category_name} active project", "#{@category_name} active projects") + " in #{@area.name.capitalize}"
    else
      "#{pluralize(@georegion_projects_count, 'active project', 'active projects')} in #{@area.name.capitalize}"
    end
  end

end
