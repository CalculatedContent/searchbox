require 'rubygems'
require 'bundler/setup'

log = File.new("logs/sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

require File.join(File.dirname(__FILE__), 'application')

set :run, false
set :environment, :production


run Sinatra::Application
