require "kemal"

require "./database"

database = Database.new

before_all do |env|
  env.response.content_type = "application/json"
end

get "/" do
  total_pages = database.db.scalar("SELECT count(id) FROM pages").as(Int64)
  total_robots = database.db.scalar("SELECT count(id) FROM robots").as(Int64)
  total_sitemaps = database.db.scalar("SELECT count(id) FROM sitemaps").as(Int64)
  total_urls = database.db.scalar("SELECT count(id) FROM urls").as(Int64)

  {
    pages:    total_pages,
    robots:   total_robots,
    sitemaps: total_sitemaps,
    urls:     total_urls,
  }.to_json
end

get "/pages" do |env|
  total = database.db.scalar("SELECT count(id) FROM pages").as(Int64)
  pages = database.db.query_all("SELECT * FROM pages WHERE definitions != ''", as: Database::Page)

  {
    total: total,
    pages: pages,
  }.to_json
end

Kemal.run
