#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-22 22:10:56 +0800
class Mijo
  class Response < Rack::Response; end

  attr :env, :req, :res

  def on(u)
    return if @matched

    @not_found = false
    found = req.path_info.match(pattern[u])
    return unless found

    @captures = Array(found&.captures)
    yield(*[*@captures, req.params.transform_keys(&:to_sym)].compact)
    if @not_found # unhandled by any http method
      res.status=404
      instance_eval(&@not_found)
    end
    halt(res.finish)

  end

  def main
    @matched = false
    yield
    res.status = 404
    @not_found ? instance_eval(&@not_found) : res.write('Not Found')
    res.finish
  end
  private :main

  def run
    yield
    @matched = true    
  end
  private :run

  def get;    run{ yield } if req.get? end
  def post;   run{ yield } if req.post? end
  def put;    run{ yield } if req.put? end
  def delete; run{ yield } if req.delete? end
  
  def not_found(&block)
    return if @matched || @not_found # already caught local 404 handler

    @not_found = block
  end

  def initialize(&block)
    @block = block
  end

  # `service` evals the url mappings 
  def service
    catch(:halt) do
      main { 
        instance_eval(&@block) 
      }
    end
  end
  
  # a subclass can provide new request/response prior to calling `service()`
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
