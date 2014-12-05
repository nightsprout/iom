class CacheProject
  @queue = :high

  def self.perform( project_id )
    project = Project.find( project_id )
    project.set_cached_sites
  end
end