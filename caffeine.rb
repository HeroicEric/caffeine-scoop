require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'haml'
require 'json'
require 'net/http'
require 'digest/md5'

# Require Models
Dir.glob("#{Dir.pwd}/models/*.rb") { |m| require "#{m.chomp}" }

set :haml, { :format => :html5 } # default for Haml format is :xhtml

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/caffeine.db")

# Finalize/initialyize DB
DataMapper.finalize
DataMapper::auto_upgrade!

def get_json(query, api)
  if api == "google" then
    url = "http://ajax.googleapis.com/ajax/services/search/news?v=1.0&q=" + query
  elsif api == "twitter"
     url = "http://search.twitter.com/search.json?q=" + query
  end

  response = Net::HTTP.get(URI.parse(url))
  return JSON.parse(response)
end

def make_query(keywords)
  @keywords = keywords.split(', ')
  @query = ""

  @keywords.each do |k|
    unless k == @keywords.last
      @query += "#{k}%20"
    else
      @query += k
    end
  end

  @query
end

def get_feed(api, keywords)
  @query = make_query(keywords)

  if api == "google" then
    return @articles = get_json(@query, api)['responseData']['results']
  elsif api == "twitter"
    return @tweets = get_json(@query, api)['results']
  end
end

################################################

get '/' do
  @articles = get_feed("google", "caffeine")
  @tweets = get_feed("twitter", "caffeine")

  haml :home
end

# Add a new Page
get '/page/new' do
	@page = Page.new
	
	haml :page_new
end

# Creat a new Page
post '/page' do
	@page = Page.create(
    :title => params[:title],
    :slug => params[:slug],
    :keywords => params[:keywords],
    :body => params[:body]
  )

	if @page.save
		status 201 # Created successfully
		redirect '/' + @page.slug
	else
		status 400 # Bad Request(
		haml :page_new
	end
end

# View a Page
get '/:slug' do
  @page = Page.first(:slug => params[:slug])
  @articles = get_feed("google", @page.keywords)
  @tweets = get_feed("twitter", "caffeine")

  haml :page
end

# Edit Page
get '/:slug/edit' do
	@page = Page.first(:slug => params[:slug])
	
	haml :page_edit
end

# Update Page
put '/:slug' do
  @page = Page.first(:slug => params[:slug])

  if @page.update(
      :title => params[:title],
      :slug => params[:slug],
      :body => params[:body]
    )
    status 201
    redirect '/' + @page.slug
  else
    status 400
    haml :page_edit
  end
end
