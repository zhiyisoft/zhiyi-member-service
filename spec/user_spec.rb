# -*- coding: utf-8 -*-

$:<< File.dirname(__FILE__) + "../lib"

require 'zhiyi_member_service/core'
require 'rspec'
require 'rack/test'
require 'sinatra'

set :environment, :test

describe '用户账号管理' do
  include Rack::Test::Methods

  def app
    Zhiyi::Member::Service
  end
  

  it "应当可以查找某一特定用户" do
    get '/user/zengyuxia' do |uid|
      last_response.should be_ok
    end
  end
end
