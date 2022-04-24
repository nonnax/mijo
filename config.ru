#!/usr/bin/env ruby
# Id$ nonnax 2022-04-22 22:11:38 +0800
require_relative 'app'
use Rack::Session::Cookie, secret: SecureRandom.hex(64)
# use Rack::Protection


run App 
