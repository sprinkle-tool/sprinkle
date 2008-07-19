module ArbitraryOptions #:nodoc:
  def self.included(base)
    base.alias_method_chain :method_missing, :arbitrary_options
  end
  
  def method_missing_with_arbitrary_options(sym, *args, &block)
    self.class.dsl_accessor sym
    send(sym, *args, &block)
  end
end
