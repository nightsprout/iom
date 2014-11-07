class CacheProject
  @queue = :high

  def self.perform( project_id )
    project = Project.find( project_id )
    ActiveRecord::Base.connection.execute("BEGIN")
    project.set_cached_sites
    ActiveRecord::Base.connection.execute("COMMIT")
  end
end