module ActivitiesHelper
  def activities_projects_list_subtitle
    if @filter_by_location
      pluralize(@project.total_entries, "#{@data.name} project", "#{@data.name} projects") + " in #{@location_name}"
    else
       location = if @site.navigate_by_country?
         pluralize(@data.total_countries(@site), 'country', 'countries')
       else
         pluralize(@data.total_regions(@site), @site.word_for_regions.singularize, @site.word_for_regions)
       end
       pluralize(@project.total_entries, "#{@data.name} project", "#{@data.name} projects") + " in #{location}"
    end
  end

end
