package :rails do
  description 'Ruby on Rails'
  version '3.2'
  
  gem 'rails'
  
  verify do
    has_executable 'rails'
  end
end