module Sprinkle
  module Sudo

    def sudo_cmd
      return "#{@delivery.try(:sudo_command) || "sudo"} " if sudo?
    end

    def sudo?
      sudo_stack.detect { |x| x==true or x==false }
    end

    def sudo_stack
      [ options[:sudo], package.sudo?, @delivery.try(:sudo?) ]
    end

  end
end
