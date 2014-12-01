# == Schema Information
#
# Table name: partners
#
#  id                :integer          not null, primary key
#  site_id           :integer
#  name              :string(255)
#  url               :string(255)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  label             :string(255)
#

class Partner < ActiveRecord::Base

  belongs_to :site

  has_attached_file :logo, :styles => {
                                      :small => {
                                        :geometry => '80x46>',
                                        :format => 'png'
                                      },
                                      :medium => {
                                        :geometry => "200x150>",
                                        :format => 'jpg'
                                      }
                                    },
                                    :storage => :s3,
                                    :s3_credentials => {
                                      :bucket             => ENV['S3_BUCKET_NAME'],
                                      :access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
                                      :secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY']
                                    }

  validates_presence_of :name, :url, :logo

  def url=(partner_url)
    write_attribute('url', partner_url.add_protocol_if_required!)
  end
end
