require 'khi-rack-mongrel2'

module Mongrel2
  class Request
    attr_reader :headers, :body, :uuid, :conn_id, :path

    class << self
      def parse(msg)
        # UUID CONN_ID PATH SIZE:HEADERS,SIZE:BODY,
        uuid, conn_id, path, rest = msg.split(' ', 4)
        headers, rest = parse_netstring(rest)
        body, _ = parse_netstring(rest)
        headers = flatten_values(Mongrel2::JSON.parse(headers))
        new(uuid, conn_id, path, headers, body)
      end

      def parse_netstring(ns)
        # SIZE:HEADERS,

        len, rest = ns.split(':', 2)
        len = len.to_i
        raise "Netstring did not end in ','" unless rest[len].chr == ','
        [rest[0, len], rest[(len + 1)..-1]]
      end
      
      def flatten_values(headers)
        headers.each do
          |k,v|
          if v.kind_of? Array
            headers[k] = v.join ", "
          end
        end
      end
    end

    def initialize(uuid, conn_id, path, headers, body)
      @uuid, @conn_id, @path, @headers, @body = uuid, conn_id, path, headers, body
      @data = headers['METHOD'] == 'JSON' ? Mongrel2::JSON.parse(body) : {}
    end

    def disconnect?
      headers['METHOD'] == 'JSON' && @data['type'] == 'disconnect'
    end

    def close?
      headers['connection'] == 'close' || headers['VERSION'] == 'HTTP/1.0'
    end
  end
end
