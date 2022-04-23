#!/usr/bin/env ruby
# Id$ nonnax 2022-04-22 22:10:56 +0800
class Mijo
  class Response<Rack::Response; end
  PATTERN=Hash.new{|h,k|h[k]=/\A#{k}\Z/}
  attr :env, :req, :res

  def on(u)
    found=req.path_info.match(PATTERN[u])
    return unless found
    yield
  end
  def main
    @matched=false
    yield
    unless @matched
      res.status=404
      res.write 'Not Found'
    end
    res.finish
  end
  def run
    yield
    @matched=true
  end
  def get
    run{yield(req.params)} if req.get?
  end

  def initialize(&block)
    @block=block
  end
  def call(env)
    @env,@req,@res=env,Rack::Request.new(env),Rack::Response.new('',200,Rack::CONTENT_TYPE=>'text/html')
    main{instance_eval(&@block)}
  end
  def session
    env['rack.session']
  end
end

module Kernel
  def Mijo(&block)
    Mijo.new(&block)
  end
end
