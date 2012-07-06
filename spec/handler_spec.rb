require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'rack/handler/mongrel2'
require 'rack'
require 'rack/lint'

describe Rack::Handler::Mongrel2 do
  before :all do
    @http11_netstring = 'UUID CON PATH 253:{"PATH":"/","user-agent":"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3","host":"localhost:6767","accept":"*/*","connection":"close","x-forwarded-for":"::1","METHOD":"GET","VERSION":"HTTP/1.1","URI":"/","PATTERN":"/"},0:,'.force_encoding("ASCII-8BIT")
    @http10_netstring = 'UUID CON PATH 229:{"PATH":"/","user-agent":"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3","accept":"*/*","connection":"close","x-forwarded-for":"::1","METHOD":"GET","VERSION":"HTTP/1.0","URI":"/","PATTERN":"/"},0:,'.force_encoding("ASCII-8BIT")
    @ct_netstring = 'UUID CON PATH 257:{"PATH":"/","user-agent":"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3","accept":"*/*","connection":"close","content-type":"text/blah","x-forwarded-for":"::1","METHOD":"POST","VERSION":"HTTP/1.1","URI":"/","PATTERN":"/"},0:,'.force_encoding("ASCII-8BIT")
    @mv_netstring = 'ajl-snd 75 /robots.txt 372:{"PATH":"/robots.txt","x-forwarded-for":"66.249.71.206","accept-encoding":"gzip,deflate","connection":"Keep-alive","accept":["text/plain","text/html"],"user-agent":"Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)","host":"dragon.actime.biz","from":"googlebot(at)googlebot.com","METHOD":"GET","VERSION":"HTTP/1.1","URI":"/robots.txt","PATTERN":"/"},0:,'.force_encoding("ASCII-8BIT")
  end
  
  it 'should satisfy Rack::Lint on HTTP 1.1 requests' do
    validate_with_lint(@http11_netstring)
  end
  
  it 'should tolerate an absent host header field (HTTP 1.0)' do
    validate_with_lint(@http10_netstring)
  end

  it 'should comply with Rack Spec about content-type in request' do
    validate_with_lint(@ct_netstring)
  end

  it 'should comply with Rack Spec about multi-valued header fields (string, not arrays)' do
    validate_with_lint(@mv_netstring)
  end

end
