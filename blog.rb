require 'bundler'
Bundler.require

require_relative "user"
require_relative "warden"
require_relative "source_file"
require_relative "redirects"

class Blog < Sinatra::Base
  use Rack::Session::Cookie, :secret => ENV['SESSION_SECRET']
  use Warden::Manager do |manager|
    manager.default_strategies :password
    manager.failure_app = Blog
  end

  helpers WardenHelpers
  helpers Sinatra::ContentFor
  use Rack::Flash

  helpers do
    def title
     title = @title ? "#{@title} - " : ""
     "#{title}Literate Programming"
    end

    def format_outline(outline)
      prev_level = 2

      "<ul>" + outline.inject("") do |html, data|
        level, link = data
        if prev_level < level
          html += "<ul>"
        elsif prev_level > level
          html += "</ul>"
        end
        prev_level = level
        html += "<li>#{link}</li>"
        html
      end + "</ul>"
    end
  end

  get '/' do
    haml :index
  end

  get '/archive' do
    @archives = SourceFile.archive_list
    haml :archive
  end

  get '/atom.xml' do
    require "rss"
    archives = SourceFile.archive_data

    rss = RSS::Maker.make("atom") do |maker|
      maker.channel.author = "Steve Klabnik"
      maker.channel.updated = SourceFile.last_updated
      maker.channel.title = "Literate Programming"
      maker.channel.id = "http://blog.steveklabnik.com/"

      archives.each do |link, title, updated, summary|
        maker.items.new_item do |item|
          item.link = link
          item.title = title
          item.updated = updated
          item.summary = summary
        end
      end
    end
    rss.to_s
  end

  get '/signup' do
    haml :signup, :layout => :full_page_layout
  end

  post '/signup' do
    User.create(params[:user])
    flash[:notice] = "All signed up! Thanks!"
    redirect '/'
  end

  get '/posts/:id' do
    begin
    source = SourceFile.new(params[:id])
    @title = source.metadata['title']
    @title_hidden = source.metadata['title-hidden']
    @content = source.content
    @outline = source.outline
    haml :post
    rescue Errno::ENOENT #lol i suck
      throw :halt, [404, "Not found"] 
    end
  end
  
  get '/login/?' do
    haml :login, :layout => :full_page_layout
  end
  
  post '/login/?' do
    authenticate!
    redirect "/"
  end
  
  get '/logout/?' do
    log_out!
    redirect '/'
  end

  post '/unauthenticated/?' do
    # If we're in our own failure app, bad things happen
    warden.custom_failure!
    status 401
    haml :login, :layout => :full_page_layout
  end

  #lol posterous
  REDIRECTS.each do |hsh|
    get hsh[:from] do
      redirect hsh[:to], 301 #yeah, this move is permanent
    end
  end

  #lol octopress
  get '/*' do
    puts "YEAH"
    post = params[:splat].first.gsub("/", "-").gsub(".html", "")
    puts "YEAH"
    pass if post.nil?
    puts "YEAH"
    redirect "posts/" + post, 301
  end
end

