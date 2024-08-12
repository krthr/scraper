require "log"
require "xml"

# require "./parsers/schemaorg"
require "../utils/http"

struct Parsers::Page
  Log = ::Log.for(self)

  getter definitions = [] of String

  def initialize; end

  def parse(content : String)
    Log.info { "Parsing page..." }

    html = XML.parse_html(content)

    html
      .xpath_nodes("//script[@type='application/ld+json']")
      .each do |node|
        @definitions << node.text

        # begin
        #   json = JSON.parse(text)

        #   json["@graph"]?.try do |graph|
        #     graph.as_a.each do |el|
        #       begin
        #         if el["@type"]? == "Product"
        #           @products << SchemaOrg::Product.from_json(el.to_json)
        #         end
        #       rescue exception
        #         Log.error { exception }
        #       end
        #     end
        #   end

        #   case json["@type"]?
        #   when "Product"
        #     begin
        #       @products << SchemaOrg::Product.from_json(text)
        #     rescue exception
        #       Log.error { exception }
        #     end
        #   end
        # rescue exception
        #   Log.error { exception }
        # end
      end
  end

  def self.download_and_parse(url)
    Log.info { "Downloading page content for #{url}" }

    body = Utils::Http.download(url, 10.seconds)

    if body
      page = Page.new
      page.parse(body)
      page
    else
      Log.error { "No body for #{url}" }
    end
  end
end
