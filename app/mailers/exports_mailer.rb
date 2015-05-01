class ExportsMailer < ActionMailer::Base
  default :from => 'CWW@taskforce.org'

  def export_results(user, site, format, parameters)
    s3 = AWS::S3.new(region: ENV['S3_REGION_NAME'] || 'us-east-1')
    bucket = s3.buckets.select do |bucket|
      bucket.name === ENV['S3_BUCKET_NAME']
    end.first

    aws_object_name = DataExporter.aws_object_name(site.id, format, parameters)
    aws_object = bucket.objects[aws_object_name]
    
    @results_url = aws_object.public_url
    
    mail(:to => user.email, :subject => "Results for your data request")
  end
end
