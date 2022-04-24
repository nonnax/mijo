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
      res.redirect '/'
    end
  end
  
  on '/r' do |params| 
    get do
      res.redirect '/login?name=nonnax'
    end
  end
  
  on '/:room' do  |room, params|
    get do
      # write json
      res.json room:, params:
    end
  end
  
  not_found do
    # 404 handler
    res.write 'Not Anywhere'
  end  

end

run App #.new
```
