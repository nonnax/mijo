# mijo, a little web router

```ruby
require 'mijo'
require 'securerandom'
require 'rack/protection'

use Rack::Session::Cookie, secret: SecureRandom.hex(64)
use Rack::Protection

App=
Mijo do
  on '/' do 
    get do |params|
      session[:name]=params[:name] || 'nonnax'
      res.write 'Hey, ' 
      res.write String(session[:name]) 
      res.write ' you got: ' 
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
  on '/:room' do 
    get do |room, params|
      res.html [room, params]
    end
  end
  not_found do |params|
    # 404 handler
    res.redirect '/?params='+String(params)
  end  
end

run App #.new
```
