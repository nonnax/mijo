#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-22 22:10:56 +0800
class Mijo
  class Response < Rack::Response; end
  H=Hash.new{|h,k| h[k]=k.transform_keys(&:to_sym)}
  attr :env, :req, :res

  def on(u)
    return if [@stop, !match(u)].any? 
    yield(*@captures)
  end
  
  # fancy writer methods
  def get;    run{ yield } if req.get? end
  def post;   run{ yield } if req.post? end
  def put;    run{ yield } if req.put? end
  def delete; run{ yield } if req.delete? end
  def not_found; run(404){ yield } end
  
  def match(u)
    req.path_info.match(pattern[u])
    .tap{ |found| @captures = *[ *Array(found&.captures), H[req.params] ].compact }
    .respond_to?(:captures)
  end

  def main
    @stop = false
    yield
    # default writer
    not_found{ 
      res.write 'Not Found'
    } 
    res.finish
  end
  private :main

  def run(status=200)
    # `run` once only
    return if @stop
    res.status=status
    yield
    @stop = true # stops searching when path_info/request_method pair matched or not_found called
  end
  private :run
  

  def initialize(&block)
    @block = block
  end

  # `service` evals the url mappings 
  def service
    catch(:halt) {
      main { 
        instance_eval(&@block) 
      }
    }
  end
  
  # a subclass can replace request/response classes for added features
  # instance vars 
  #  `@env` = env
  #  `@req` = a_request_class
  #  `@res` = a_response_class

  def call(env)
    @env = env
    @req = Rack::Request.new(env)
    @res = Rack::Response.new('', 200, Rack::CONTENT_TYPE => 'text/html')
    service
  end

  def halt(response)
    throw :halt, response
  end

  def session
    env['rack.session'] || raise('You need to set up a session middleware. `use Rack::Session`')
  end
  
  # `pattern` is called by on to match path_info with compiled path
  def pattern
    Hash.new { |h, k| h[k] = compile(k) }
  end

  def compile(u)
    u.gsub(/:\w+/) { '([^/?#]+)' }
     .then { |comp| %r{^#{comp}/?$} }
  end
end

module Kernel
  def Mijo(&block)
    Mijo.new(&block)
  end
end
