class BlankSlate
  instance_methods.each do |m| 
    undef_method(m) unless %w( __send__ __id__ send class inspect instance_eval instance_variables ).include?(m)
  end
end
