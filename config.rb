activate :i18n, :langs => [:en, :id]

activate :syntax, :line_numbers => true
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :footnotes => true

activate :deploy do |deploy|
  deploy.method = :git
  deploy.branch = 'master'
end

activate :blog do |blog|
  blog.permalink = "{lang}/{title}.html"
  blog.sources = "{year}-{month}-{day}-{title}.{lang}.html"

  blog.taglink = "tags/{tag}.html"
  # blog.default_extension = ".markdown"

  blog.prefix = "blog"
  blog.layout = "blog"
  blog.summary_length = 250
  blog.tag_template = "tag.html"
  blog.calendar_template = nil
end

page "/feed.xml", layout: false

###
# Helpers
###

# Reload the browser automatically whenever files change
activate :livereload

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
end
