module Sprinkle
  module Installers
    # = Binary Installer
    # 
    #
    class Binary < Installer
      def initialize(parent, source, options = {}, &block) #:nodoc:
        @source = source
        super parent, options, &block
      end

      def download_commands #:nodoc:
        [ "wget -cq --directory-prefix='#{@options[:archives]}' #{@source}" ]
      end

      def install_commands #:nodoc:
        commands = [ "bash -c 'wget -cq --directory-prefix=\'#{@options[:archives]}\' #{@source} "]
        # TODO check archive type
        commands << "cd #{@options[:prefix]} && tar xfvz #{@options[:archives]}/#{@source.split("/").last}'"
      end
    end
  end
end
