class Appreview < ActiveRecord::Base
  attr_accessible :appname, :star, :title, :author, :content, :date, :country, :version,
									:appdetail_id
	belongs_to :appdetail
end
