activate :i18n, :langs => [:en, :id]

activate :syntax, :line_numbers => true
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :footnotes => true

activate :deploy do |deploy|
  deploy.method = :git
  deploy.branch = 'master'

  if ENV["TRAVIS_BUILD_NUMBER"] then
    deploy.commit_message += " (Travis Build \##{ENV["TRAVIS_BUILD_NUMBER"]})"
  end
end

activate :blog do |blog|
  blog.permalink = "{lang}/{title}.html"
  blog.sources = "{year}-{month}-{day}-{title}.{lang}.html"

  blog.taglink = "tags/{tag}.html"
  # blog.default_extension = ".markdown"

  blog.prefix = "blog"
  blog.summary_length = 250
  blog.tag_template = "tag.html"
  blog.calendar_template = nil
end

page "/feed.xml", layout: false
page "/id/feed.xml", layout: false

#########
# Helpers
#########

helpers do
  def current_lang
    current_page.metadata[:locals][:lang]
  end

  def is_tag_page
    current_page.metadata[:locals]["page_type"] == "tag"
  end

  def localise_current_link(target_lang)
    return localise_current_article_link(target_lang) if article?

    source_page_path = current_page.path
    source_page_path = "index.html" if is_tag_page
    page = default_lang?(current_lang) ? source_page_path : source_page_path.gsub("#{current_lang}/", "")
    page = page.gsub("index.html", "")
    localise_page_link(page, target_lang)
  end

  def localise_page_link(page, target_lang)
    lang = default_lang?(target_lang) ? "" : "#{target_lang}/"
    "/#{lang}#{page}"
  end

  private
  def default_lang? lang
    lang == I18n.default_locale
  end

  def article?
    !current_article.nil?
  end

  def localise_current_article_link(target_lang)
    source_lang = current_lang
    current_article.url.gsub("/#{current_lang}/", "/#{target_lang}/")
  end
end

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
end
