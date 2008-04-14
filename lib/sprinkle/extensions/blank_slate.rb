# Kudos to the excellent metaprogramming article at: http://www.artima.com/rubycs/articles/ruby_as_dslP.html

class BlankSlate
  instance_methods.each do |m| 
    undef_method(m) unless %w( __send__ __id__ send class inspect instance_eval instance_variables ).include?(m)
  end
end
