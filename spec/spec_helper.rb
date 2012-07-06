$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspec'

module Helpers
  def validate_with_lint(req_netstring)
    req = Mongrel2::Request.parse(req_netstring)
    conn = double("mock conn")
    conn.stub(:recv) {req}
    conn.stub(:reply) {nil}
    Mongrel2::Connection.stub(:new) { conn }

    # Wrap a dummy app with two Lint guards (before and after)
    app = lambda {|e| return 200, {"content-type"=>"text/crap"}, [""]}
    app = Rack::Lint.new app
    app = Rack::Lint.new app
  
    conn_th = Thread.new do
      Rack::Handler::Mongrel2.run(app,{recv: "r", send: "s", uuid: "i"})
    end
    
    sleep 0.1
    req.stub(:disconnect?) {true}
    Thread.kill conn_th
    conn_th.join
  end
end
  
RSpec.configure do |config|
  config.include Helpers
end
