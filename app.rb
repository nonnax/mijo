#!/usr/bin/env ruby
# Id$ nonnax 2022-04-22 22:11:38 +0800
require_relative 'clone'
require 'securerandom'
require 'rack/protection'
require 'json'

App=
Mijo do

  on '/' do |params| 
    get do
      unless session[:name]
        res.redirect '/login'
      else
        res.write String(session[:name])
        res.write ' you got: '
        res.write params.inspect
      end
    end
    not_found do # unhandled url match
      res.write 'Nada'
    end
  end
  
  on '/login' do |params|
    get do
      session[:name]=params[:name] || 'mijo'
      res.redirect '/'+'?name='+String(session[:name])
    end
  end
  
  on '/r' do |params| 
    get do
      res.redirect '/login?name=nonnax'
    end
  end
  on '/x' do |params| 
    not_found do
      res.write 'not in X'
    end
  end
  
  on '/:room' do  |room, params|
    get do
      # write json
      res.json room:, params:
    end
  end
  
  # not_found do
    # # 404 handler
    # res.write 'Not Anywhere'
  # end

end

