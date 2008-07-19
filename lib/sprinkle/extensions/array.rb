class Array #:nodoc:
  def to_task_name
    collect(&:to_task_name).join('_')
  end
end