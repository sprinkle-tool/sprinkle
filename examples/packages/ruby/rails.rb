package :rails do
  description 'Ruby on Rails'
  gem 'rails'
  version '2.1.0'
  
  verify do
    has_executable 'rails'
  end
end