module DataSourcesHelper
  def data_source_projects_list_subtitle
    if @filter_by_location
      pluralize(@data_sources_project_count, "#{@data.name} project", "#{@data.name} projects") + " in #{@location_name}"
    else
       location = if @site.navigate_by_country?
         pluralize(@data.total_countries(@site), 'country', 'countries')
       else
         pluralize(@data.total_regions(@site), @site.word_for_regions.singularize, @site.word_for_regions)
       end
       pluralize(@data_sources_project_count, "#{@data.name} project", "#{@data.name} projects") + " in #{location}"
    end
  end
end