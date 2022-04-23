#!/usr/bin/env ruby
# Id$ nonnax 2022-04-23 15:26:55 +0800
require_relative 'lib/mijo'

# acts as clientware
class Client
  def initialize(&block)
    @app=Mijo.new(&block)
  end
  def call(env)
    status, headers, body = @app.call(env)
    [status, headers, body.map(&:upcase)]
  end
end

def Mijo(&block)
  Client.new(&block)
end
