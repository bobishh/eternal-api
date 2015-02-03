require 'rubygems'
require 'bundler'
require 'dotenv'
Bundler.require
Dotenv.load

require './app'

map '/start' do
  run EternalVoidApi
end
