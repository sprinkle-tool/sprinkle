module Sprinkle
  module Verifiers
    # = Ruby Verifiers
    #
    # The verifiers in this module are ruby specific. 
    module Ruby
      Sprinkle::Verify.register(Sprinkle::Verifiers::Ruby)
      
      # Checks if ruby can require the <tt>files</tt> given. <tt>rubygems</tt>
      # is always included first.
      def ruby_can_load(*files)
        # Always include rubygems first
        files = files.unshift('rubygems').collect { |x| "require '#{x}'" }
        
        @commands << "ruby -e \"#{files.join(';')}\""
      end
      
      # Checks if a gem exists by calling "sudo gem list" and grepping against it.
      def has_gem(name, version=nil)
        version = version.nil? ? '' : "--version '#{version}'"
        @commands << "sudo gem list '#{name}' --installed #{version} > /dev/null"
      end
    end
  end
end