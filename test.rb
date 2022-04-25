#!/usr/bin/env ruby
# Id$ nonnax 2022-04-24 19:13:24 +0800
require 'rack'
require 'rack/test'
require 'test/unit'

OUTER_APP = Rack::Builder.parse_file("config.ru").first

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def test_root
    get "/"
     assert_equal last_response.headers, {"Location"=>'/login'}
  end
  def test_root_login
    get "/login?name=nonnax"
     assert_equal last_response.status, 302
     assert_match last_response.body, 'nonnax'
  end
  def test_redirect
    get "/r"
     assert_equal last_response.headers, {"Location"=>'/login?name=nonnax'}
  end
  def test_local_not_found
    get "/x"
     assert_equal last_response.status, 404
  end
  def test_global_not_found
    get "/global/x"
     assert_equal last_response.status, 302
  end
  def test_room
    get "/room"
     assert_equal 'application/json', last_response.headers[Rack::CONTENT_TYPE]
  end
end
