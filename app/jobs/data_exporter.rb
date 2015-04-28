class DataExporter
  @queue = :high

  def self.perform(user_id, site_id, format, parameters = {})
    site = Site.find(site_id)
    user = User.find(user_id)

    s3 = AWS::S3.new(region: 'us-east-1')
    object_name = aws_object_name(site_id, format)

    case format.to_sym
    when :csv
      data = Project.to_csv(site, parameters)
      
    when :excel
      data = Project.to_excel(site, parameters)
      
    when :kml
      data = Project.to_kml(site, parameters)
      
    when :geojson
      data = Project.to_geojson(site, parameters)
      
    else
      raise ArgumentError, "Invalid export format"
    end

    s3.bucket(ENV['S3_BUCKET_NAME'])[aws_key].write(data)
    ExportsMailer.export_results(user, site, format).deliver
  end

  private

  def self.aws_object_name(site_id, format, parameters)
    "export-#{site_id}-#{parameters.to_s.hash}\.#{format}"
  end

end
