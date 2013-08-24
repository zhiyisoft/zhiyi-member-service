require 'sinatra'

get '/user/:uid' do |uid|
  "Hello, #{uid}"
end


