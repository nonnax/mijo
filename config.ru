#!/usr/bin/env ruby
# Id$ nonnax 2022-04-22 22:11:38 +0800
require_relative 'clientware'
require 'securerandom'
require 'rack/protection'

use Rack::Session::Cookie, secret: SecureRandom.hex(64)
use Rack::Protection

App=
Mijo do
  on '/' do 
    get do |params|
      session[:name]=params[:name] || 'nonnax'
      res.write 'hey,' 
      res.write String(session[:name]) 
      res.write ' you got ' 
      res.write params.inspect
    end
  end
  on '/r' do 
    get do
      res.redirect '/'
    end
    post do |params|
      res.write String(params)
    end
  end
end

run App #.new
