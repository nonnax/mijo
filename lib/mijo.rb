#!/usr/bin/env ruby
# Id$ nonnax 2022-04-22 22:10:56 +0800
class Mijo
  class Response<Rack::Response; end
  
  attr :env, :req, :res

  def on(u)
    found=req.path_info.match(pattern[u])
    return unless found
    @captures=Array(found&.captures)
    yield
  end

  def main
    @matched=false
    yield
    unless @matched
      res.status = 404
      defined?(@not_found) ? instance_eval(&@not_found) : res.write('Not Found')
    end
    res.finish
  end
  private :main
  
  def run
    yield [*@captures,req.params.transform_keys(&:to_sym)].compact
    @matched=true
  end
  private :run
  
  def get
    run{|params|yield(*params)} if req.get?
  end
  
  def post
    run{|params|yield(*params)} if req.post?
  end

  def delete
    run{|params|yield(*params)} if req.delete?
  end
  
  def not_found(&block)
     @not_found = block
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
  
  def pattern
    Hash.new{ |h,k| h[k]=compile_pattern(k) } 
  end

  def compile_pattern(base)
    base.gsub(/:\w+/){ |match| '([^/?#]+)'}
    .then{|compiled_path| /^#{compiled_path}\/?$/}
  end
end

module Kernel
  def Mijo(&block)
    Mijo.new(&block)
  end
end
