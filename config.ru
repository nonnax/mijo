#!/usr/bin/env ruby
# Id$ nonnax 2022-04-22 22:11:38 +0800
require_relative 'lib/mijo'
require 'securerandom'
require 'rack/protection'

use Rack::Session::Cookie, secret: SecureRandom.hex(64)
use Rack::Protection

App=
Mijo do
  get '/' do |params|
    session[:name]='nonnax'
    'hey !'+String(session[:name])+' '+params.inspect
  end
  get '/r' do |params|
    res.redirect '/'
  end
end

pp Mijo::Handler.map

run App #.new
