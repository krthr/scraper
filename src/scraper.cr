require "log"

require "./database"
require "./scraper/parsers/*"
require "./scraper/queue"

class Scraper
  VERSION = "0.1.0"

  Log = ::Log.for(self)

  def initialize
    @database = Database.new
    @database.create_tables

    self.process_robots
    self.process_sitemaps
    self.process_urls
  end

  def process_robots
    spawn do
      Log.info { "Starting Robots processor..." }

      loop do
        robots = @database.first("robots", Database::Robots)

        if robots
          begin
            parsed_robots = Parsers::Robots.download_and_parse(robots.host)

            if parsed_robots
              parsed_robots.directives.each do |directive|
                directive.rules["sitemap"].each do |sitemap_url|
                  @database.db.exec("INSERT OR IGNORE INTO sitemaps(url) VALUES(?)", sitemap_url)
                end
              end
            end

            @database.delete("robots", robots.id)
          rescue exception
            Log.error { exception }
          end
        end

        sleep 1
      end
    end
  end

  def process_sitemaps
    spawn do
      Log.info { "Starting Sitemaps processor..." }

      loop do
        sitemap = @database.first("sitemaps", Database::Sitemap)

        if sitemap
          begin
            parsed_sitemap = Parsers::Sitemap.download_and_parse(sitemap.url)

            if parsed_sitemap
              parsed_sitemap.sitemaps_urls.each do |url|
                @database.db.exec("INSERT OR IGNORE INTO sitemaps(url) VALUES(?)", url)
              end

              parsed_sitemap.urls.each do |url|
                @database.db.exec("INSERT OR IGNORE INTO urls(url) VALUES(?)", url)
              end
            end

            @database.delete("sitemaps", sitemap.id)
          rescue exception
            Log.error { exception }
          end
        end

        sleep 1
      end
    end
  end

  def process_urls
    spawn do
      Log.info { "Starting Pages processor..." }

      pages_queue = Queue.new

      loop do
        url = @database.first("urls", Database::Url)

        if url
          page_url = url.url
          @database.delete("urls", url.id)

          pages_queue.add do
            begin
              parsed_page = Parsers::Page.download_and_parse(page_url)

              if parsed_page
                @database.db.exec(
                  "INSERT OR REPLACE INTO pages(url, definitions)
                  VALUES(?, ?)",
                  page_url,
                  parsed_page.definitions.to_json
                )
              end
            rescue exception
              Log.error { exception }

              @database.db.exec("INSERT OR IGNORE INTO urls(url) VALUES(?)", page_url)
            end
          end
        end

        sleep 0.5
      end
    end
  end

  # def run
  # end
end

Scraper.new
sleep
