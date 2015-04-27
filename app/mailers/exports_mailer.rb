class ExportsMailer < ActionMailer::Base
  default :from => 'CWW@taskforce.org'

  def export_results(user, site_id, format)
    s3 = AWS::S3.new(region: 'us-east-1')
    aws_object_name = DataExporter.aws_object_name(site_id, format)
    aws_object = s3.bucket(ENV['S3_BUCKET_NAME'])[aws_object_key]
    
    @results_url = aws_object.public_url
    
    mail(:to => user.email, :subject => "Results for your data request")
  end
end
