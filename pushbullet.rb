# frozen_string_literal: true

require 'net/http'
require 'uri'

class Pushbullet
  PUSHBULLET_URI = 'https://api.pushbullet.com/v2/pushes'
  def initialize(access_token)
    @access_token = access_token
  end

  def call(title, message)
    uri = URI(PUSHBULLET_URI)

    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json', 'Access-Token' => @access_token)
    req.body = { "type": 'note', "title": title, body: message }.to_json
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
  end
end
