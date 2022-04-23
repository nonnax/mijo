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
    yield req.params.transform_keys(&:to_sym)
    @matched=true
  end
  def get
    run{|params|yield(params)} if req.get?
  end
  def post
    run{|params|yield(params)} if req.get?
  end

  def initialize(&block)
    @block=block
  end
  def service
    # subclass may provide custom request/response prior to calling `service()` in `call()`
    main{ instance_eval(&@block) }
  end
  def call(env)
    @env=env
    @req=Rack::Request.new(env)
    @res=Rack::Response.new('', 200, Rack::CONTENT_TYPE=>'text/html')
    service
  end
  def session
    env['rack.session'] || raise('You need to set up a session middleware. `use Rack::Session`')
  end
end

module Kernel
  def Mijo(&block)
    Mijo.new(&block)
  end
end
