module Sprinkle
  module Sudo
    
    def sudo_cmd
      return "#{@delivery.try(:sudo_command) || "sudo"} " if sudo?
    end

    def sudo?
      options[:sudo] or package.sudo? or @delivery.try(:sudo?)
    end
    
  end
end
