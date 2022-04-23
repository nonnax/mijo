#!/usr/bin/env ruby
# Id$ nonnax 2022-04-22 22:11:38 +0800
require_relative 'clone'
require 'securerandom'
require 'rack/protection'

use Rack::Session::Cookie, secret: SecureRandom.hex(64)
use Rack::Protection

App=
Mijo do
  on '/' do |params| 
    get do 
      unless session[:name]
        res.redirect '/login' 
      else
        res.write 'Hey, ' 
        res.write String(session[:name]) 
        res.write ' you got: ' 
        res.write params.inspect
      end
    end
  end
  on '/login' do |params|
    get do
      session[:name]=params[:name] || 'mijo'
      res.redirect '/'
    end
  end
  on '/r' do |params| 
    get do
      res.redirect '/login?name=nonnax'
    end
    not_found do
      # local 404 handler
      res.write 'Not in r: '+ String(room)
    end  
  end
  on '/:room' do  |room|
    get do
      res.write 'Found it in room: '+ String(room)
    end
    not_found do
      # local 404 handler
      res.write 'Not in room: '+ String(room)
    end  
  end
  not_found do
    # 404 handler
    res.write 'Not Anywhere'
  end  
end

run App #.new
