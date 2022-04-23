# mijo, a little web router

```ruby
require 'mijo'
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
    session[:name]=params[:name] || 'nonnax'
    res.redirect '/'
  end
  on '/r' do |params|
    get do
      res.redirect '/'
    end
    post do
      res.write String(params)
    end
  end
  on '/:room' do |room, params|
    get do 
      res.html [room, params]
    end
    not_found do
      # local 404 handler
      # path was matched but no http method handler
      res.write 'Not in room: '+ String(room)
    end    
  end
  not_found do
    # 404 handler
    res.redirect '/'
  end  
end

run App #.new
```
