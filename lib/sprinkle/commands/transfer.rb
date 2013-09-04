module Sprinkle
  module Commands
    class Transfer < Command
      
      attr_reader :source, :destination, :opts
      
      def initialize(source, destination, opts={})
        @source = source
        @destination = destination
        @opts = opts
      end
      
      def recursive?
        !!@opts[:recursive]
      end
      
      def inspect
        ":TRANSFER, src: #{source}, dest: #{destination}, opts: #{@opts.inspect}"
      end
      
      def eql?(a,b)
        a.source == b.source &&
        a.destionation == b.destination &&
        a.opts == b.opts
      end
      
    end
  end
end