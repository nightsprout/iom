class DataExporter
  @queue = :high

  def self.perform(site_id, format)
    site = Site.find(site_id)
    s3 = AWS::S3.new(region: 'us-east-1')
    aws_key = aws_file_key(site_id, format)    

    case format.to_sym
    when :csv
      data = Project.to_csv(site, {})
      
    when :excel
      data = Project.to_excel(site, {})
      
    when :kml
      data = Project.to_kml(site, {})
      
    when :geojson
      data = Project.to_geojson(site, {})
      
    else
      raise ArgumentError, "Invalid export format"
    end

    s3.bucket(ENV['S3_BUCKET_NAME'])[aws_key].write(data)
  end

  private

  def self.aws_file_key(site_id, format)
    "export-#{site_id}-#{format}"
  end

end
