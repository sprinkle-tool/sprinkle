class BlankSlate #:nodoc:
  instance_methods.each do |m|
    undef_method(m) unless %w( __send__ __id__ send class inspect instance_eval instance_variables object_id ).include?(m.to_s)
  end
end
