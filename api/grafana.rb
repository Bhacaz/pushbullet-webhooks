# frozen_string_literal: true

require 'json'
require 'base64'
require_relative '../pushbullet'

Handler = Proc.new do |req, res|
  body = JSON.parse(req.body)
  basic_auth = req.header['authorization'].first
  unless basic_auth
    req.status = 401
    next
  end

  basic_auth.gsub!('Basic ', '')

  access_token = Base64.decode64(basic_auth).split(':')[0]
  res.status = 200
  Pushbullet.new(access_token).call(body['title'], body['message'])
end
