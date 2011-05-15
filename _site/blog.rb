require 'sinatra/base'

require_relative "redirects"

class Blog < Sinatra::Base 
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "_site") }

  before do
    response.headers['Cache-Control'] = 'public, max-age=31557600' if settings.environment == "production"
  end

  get '/' do
    File.read('_site/index.html')
  end

  REDIRECTS.each do |hsh|
    get hsh[:from] do
      redirect hsh[:to], 301 #yeah, this move is permanent
    end
  end

end

