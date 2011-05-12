require 'rubygems'
require 'bundler/setup'
require "sinatra"

require"./blog"

run Blog.new

