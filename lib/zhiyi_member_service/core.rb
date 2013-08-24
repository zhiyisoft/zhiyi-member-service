require 'sinatra'
require 'sinatra/r18n'

module Zhiyi
  module Member
    class Service < Sinatra::Base
      register Sinatra::R18n

      get '/user/:uid' do |uid|
        "Hello, #{uid}"
      end

      post '/user/add' do
        p params
      end
    end
  end
end


