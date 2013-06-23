module Sprinkle
  module Actors
    class SSHConnectionCache #:nodoc:
      def initialize(options={}) 
        @cache = {}
        @gateway = Net::SSH::Gateway.new(options[:gateway], options[:user]) if options[:gateway]
      end
      def start(host, user, opts={})
        key="#{host}/#{user}#{opts.to_s}"
        if @gateway
          @cache[key] ||= @gateway.ssh(host, user, opts)
        else
          @cache[key] ||= Net::SSH.start(host, user, opts)
        end
      end
      def reconnect(host)
        @cache.delete_if do |k,v| 
          (v.close; true) if k =~ /^#{host}\//
        end
      end
      def shutdown!
        @gateway.shutdown! if @gateway
      end
    end
  end
end