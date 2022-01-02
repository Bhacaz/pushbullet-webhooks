# frozen_string_literal: true

require 'json'
require 'base64'
require 'cgi'
require_relative '../pushbullet'

class PlexWebhookParser
  class << self
    def movieMessage(body)
      body['Metadata']['title']
    end

    def tvShowMessage(body)
      tvShowTitle = body['Metadata']['grandparentTitle']
      season = body['Metadata']['parentTitle']
      episode = body['Metadata']['index']

      "#{tvShowTitle} : #{season}, Episode #{episode}"
    end
  end
end

Handler = proc do |req, res|
  apiKey = CGI.parse(req.query_string).transform_values(&:first)['apiKey']
  body = JSON.parse(req.body.split("\r\n")[4])

  event = body['event']
  next if event != 'media.play'

  user = body['Account']['title']
  message =
    if body['Metadata']['librarySectionType'] == 'show'
      PlexWebhookParser.tvShowMessage(body)
    else
      PlexWebhookParser.movieMessage(body)
    end

  unless apiKey
    req.status = 401
    next
  end

  res.status = 200
  message = "#{user}\n#{message}"
  Pushbullet.new(apiKey).call('Start playing', message)
end
