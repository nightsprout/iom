# == Schema Information
#
# Table name: layers
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  description   :text
#  credits       :text
#  date          :datetime
#  min           :float
#  max           :float
#  units         :string(255)
#  status        :boolean
#  cartodb_table :string(255)
#  sql           :text
#  long_title    :string(255)
#

class Layer < ActiveRecord::Base
  # attr_accessible :site_layers_attributes
  has_many  :site_layers
  has_many  :site, :through => :site_layers

  validates_presence_of :title, :long_title, :cartodb_table, :min, :max
  # accepts_nested_attributes_for :site_layers

  # to get only id and name
  def self.get_select_values
    scoped.select("id,title").order("title ASC")
  end  
end
