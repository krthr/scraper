require "json"
require "log"

require "../utils/http"

struct Parsers::Robots
  Log = ::Log.for(self)

  include JSON::Serializable

  struct Directive
    include JSON::Serializable

    property user_agent : String
    property rules : Hash(String, Array(String))

    def initialize(@user_agent : String)
      @rules = Hash(String, Array(String)).new { |hash, key|
        hash[key] = [] of String
      }
    end

    def add_rule(directive : String, value : String)
      @rules[directive].push(value)
    end
  end

  getter directives : Array(Directive)

  def initialize
    @directives = [] of Directive
  end

  def parse(content : String)
    Log.info { "Parsing content..." }

    current_directive : Directive? = nil

    content.each_line do |line|
      line = line.strip

      # Skip comments and empty lines
      next if line.empty? || line.starts_with?("#")

      key, value = line.split(":", 2).map(&.strip)

      if key.downcase == "user-agent"
        current_directive = Directive.new(value)
        @directives << current_directive
      elsif current_directive
        current_directive.add_rule(key.downcase, value)
      end
    end
  end

  def self.download_and_parse(host : String)
    url = URI.new(
      scheme: "https",
      host: host,
      path: "/robots.txt"
    )

    Log.info { "Downloading file using url=#{url}" }

    body = Utils::Http.download(url)

    if body
      robots = Robots.new
      robots.parse(body)
      robots
    else
      Log.error { "No body for #{url}" }
    end
  end
end
