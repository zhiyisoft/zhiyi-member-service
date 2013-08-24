require 'sinatra'
require 'sinatra/r18n'

$:<< File.dirname(__FILE__) + "/."
require 'member'

module Zhiyi
  module Member
    class Service < Sinatra::Base
      register Sinatra::R18n

      configure :production, :development do
        enable :logging
      end

      before do
        Zhiyi::Member.load(File.dirname(__FILE__) + "/../../config/ldap.yaml") unless Zhiyi::Member::Ldap.config
      end

      get '/user/:uid' do |uid|
        "Hello, #{uid}"
      end

      post '/user/add' do
        Zhiyi::Member::User.delete(params["uid"])
        Zhiyi::Member::User.add ({ uid: params["uid"],
                                   sn: params["sn"],
                                   cn: params["cn"],
                                   displayName: params["sn"] + params["cn"], 
                                   userPassword: "123456"})
      end
    end
  end
end


