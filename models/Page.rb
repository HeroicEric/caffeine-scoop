class Page
	include DataMapper::Resource
	
	property :id,         Serial
	property :title,      String
	property :slug,       String
  property :keywords,   String, :length => 1024
	property :body,       Text
	property :created_at, DateTime
	property :updated_at, DateTime
	
	def url
		"/#{slug}"
	end

  def self.make_slug(title)
		title.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_')
	end

end
