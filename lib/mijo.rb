#!/usr/bin/env ruby
# Id$ nonnax 2022-04-22 22:10:56 +0800
class Mijo
  class Response<Rack::Response; end
  module Handler    
    def get(u, &block)
      Handler.map[u]['GET'] = block
    end
    def self.map
      @map ||=Hash.new{|h,k| h[k]={}}
    end
  end
  include Handler

  attr :env, :req, :res

  def initialize(&block)
    @block=block
    instance_eval(&block)
  end
  def call(env)
    @env,@req,@res,status=env,Rack::Request.new(env),Rack::Response.new('',200,Rack::CONTENT_TYPE=>'text/html')
    p,m = env.values_at('PATH_INFO', 'REQUEST_METHOD')
    body=instance_exec(req.params.transform_keys(&:to_sym), &Handler.map[p][m]) rescue nil
    begin body='Not Found'; res.status=404 end unless body
    res.write body
    res.finish
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
