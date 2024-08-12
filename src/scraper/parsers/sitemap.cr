require "json"
require "log"
require "xml"

require "../utils/http"

struct Parsers::Sitemap
  include JSON::Serializable

  Log = ::Log.for(self)

  getter sitemaps_urls : Array(String)
  getter urls : Array(String)

  def initialize(@sitemaps_urls = [] of String, @urls = [] of String)
  end

  def parse(content : String)
    xml = XML.parse_html(content)

    @sitemaps_urls = xml.xpath_nodes("//sitemap/loc").map &.text
    @urls = xml.xpath_nodes("//url/loc").map &.text
  end

  def self.download_and_parse(url : String)
    Log.info { "Downloading file using url=#{url}" }

    body = Utils::Http.download(url, 10.seconds)

    if body
      sitemap = Sitemap.new
      sitemap.parse(body)
      sitemap
    else
      Log.error { "No body for #{url}" }
    end
  end
end
