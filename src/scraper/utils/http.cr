require "http/client"

module Utils::Http
  class Timeout < Exception
    getter request_timeout : Time::Span

    def initialize(@request_timeout : Time::Span)
    end
  end

  class RequestError < Exception
    getter response : HTTP::Client::Response

    def initialize(@response : HTTP::Client::Response)
    end
  end

  def self.download(url : String | URI, request_timeout = 5.seconds)
    ch = Channel(HTTP::Client::Response).new

    spawn do
      response = HTTP::Client.get(url)
      ch.send response
    end

    select
    when response = ch.receive
      if response.success?
        response.body
      else
        raise RequestError.new(response)
      end
    when timeout(request_timeout)
      raise Timeout.new(request_timeout)
    end
  end
end
