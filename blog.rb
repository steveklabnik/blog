require 'sinatra/base'


class Blog < Sinatra::Base 
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "_site") }

  before do
    response.headers['Cache-Control'] = 'public, max-age=31557600' # 1 year
  end

  get '/' do
    File.read('_site/index.html')
  end
end

