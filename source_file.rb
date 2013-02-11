# about 3/4ths of this is based on https://github.com/mojombo/jekyll/blob/master/lib/jekyll/convertible.rb

# https://github.com/tanoku/redcarpet/pull/91
class StripDown < Redcarpet::Render::Base
  # Methods where the first argument is the text content
  [
    # block-level calls
    :block_code, :block_quote,
    :block_html, :header, :list,
    :list_item, :paragraph,

    # span-level calls
    :autolink, :codespan, :double_emphasis,
    :emphasis, :raw_html, :triple_emphasis,
    :strikethrough, :superscript,

    # low level rendering
    :entity, :normal_text
  ].each do |method|
    define_method method do |*args|
      args.first
    end
  end

  # Other methods where the text content is in another argument
  def link(link, title, content)
    content
  end
end

class RelRenderer < Redcarpet::Render::HTML
  attr_accessor :outline

  def initialize
    @outline = []
    super
  end

  def link(link, title, content)
    "<a href='#{link}' rel='#{title}'>#{content}</a>"
  end

  def header(text, header_level)
    text_slug = text.to_s.gsub(/\W/, "_").downcase
    
    self.outline << [header_level, "<a href='##{text_slug}'>#{text}</a>"]

    "<h#{header_level} id='#{text_slug}'>#{text}</h#{header_level}>"
  end
end

class SourceFile
  attr_accessor :content
  attr_accessor :metadata
  attr_accessor :outline

  def self.archive_list
    @archive_list ||= Dir.glob("posts/*.{markdown,md}").sort.reverse.collect do |filename|
      content = File.read(filename)
      content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      title = YAML.load($1)["title"]
      [title, "/#{filename.gsub(/\..*?$/, "")}"]
    end
  end

  def self.archive_data
    @archive_data ||= Dir.glob("posts/*.{markdown,md}").sort.reverse.collect do |filename|
      content = File.read(filename)
      content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      title = YAML.load($1)["title"]
      r = Redcarpet::Markdown.new(StripDown, :fenced_code_blocks => true)
      summary = r.render($')[0,200] + "..."
      filename =~ /\/(\d\d\d\d-\d\d-\d\d)/
      updated = Date.strptime($1).to_datetime.rfc2822
      ["http://blog.steveklabnik.com/#{filename.gsub(/\..*?$/, "")}", title, updated, summary]
    end
  end

  def self.last_updated
    filename = Dir.glob("posts/*.{markdown,md}").sort.reverse.first
    filename =~ /\/(\d\d\d\d-\d\d-\d\d)/
    Date.strptime($1).to_datetime.rfc2822
  end

  def initialize(name)
    base = "posts"
    content = ""
    
    # oh god this is bad.
    begin 
      content = File.read(File.join(base, "#{name}.markdown"))
    rescue
      content = File.read(File.join(base, "#{name}.md"))
    end

    if content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      renderer = RelRenderer.new
      r = Redcarpet::Markdown.new(renderer, :fenced_code_blocks => true)
      self.content = r.render($')
      self.outline = renderer.outline

      begin
        self.metadata = YAML.load($1)
      rescue => e
        puts "YAML Exception reading #{name}: #{e.message}"
      end
    end

    self.metadata ||= {}
  end
end
