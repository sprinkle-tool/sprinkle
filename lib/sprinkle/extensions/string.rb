class String #:nodoc:
  
  # REVISIT: what chars shall we allow in task names?
  def to_task_name
    s = downcase
    s.gsub!(/-/, '_') # all - to _ chars
    s
  end
  
end