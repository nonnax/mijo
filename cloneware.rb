#!/usr/bin/env ruby
# Id$ nonnax 2022-04-23 15:26:55 +0800
require_relative 'lib/mijo'

# acts as middleware
class Clone
  def initialize(&block)
    @app=Mijo.new(&block)
  end
  def call(env)
    @app.call(env)
  end
end

def Mijo(&block)
  Clone.new(&block)
end
