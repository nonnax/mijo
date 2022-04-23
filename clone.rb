#!/usr/bin/env ruby
# Id$ nonnax 2022-04-23 15:48:11 +0800
require_relative 'lib/mijo'

class Clone<Mijo
  class Response<Rack::Response
    def puts(s,type:'html')
      ctype=
      ['text/plain; charset=utf-8',
      'text/html; charset=utf-8',
      'application/json']
      .grep(Regexp.new(type))
      .pop
      
      headers[Rack::CONTENT_TYPE]=ctype
      status=200
      write s
    end
    def text(s)      
      puts s, type:'plain'
    end
    def html(s)
      puts s, type:'html'
    end
    def json(**h)
      puts h.to_json, type:'json'
    end
  end
  def call(env)
    # the three musketeers
    @env, @req, @res = env, Rack::Request.new(env), Clone::Response.new('',200)
    service
  end
end

def Mijo(&block)
  Clone.new(&block)
end

