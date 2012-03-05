desc "Make a new post"
task :new_post, :title do |t, args|
  args.with_defaults(:title => 'new-post')
  title = args.title
  date = Time.now.strftime('%Y-%m-%d')
  filename = "posts/#{date}-#{title.downcase.gsub(/\W/, "-")}.md"

  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "---"
  end
end
