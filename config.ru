require 'rubygems'
require 'bundler'

Bundler.require

set :run, false
set :environment, :production

require 'caffeine'

run Sinatra::Application
