require 'rubygems'
require 'sinatra/r18n'

require File.join(File.dirname(__FILE__), 'lib/zhiyi_member_service')
run Zhiyi::Member::Service