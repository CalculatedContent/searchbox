require 'rubygems'
require 'bundler/setup'


log = File.new("logs/sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)


get '/' do
  "Hello world, it's #{Time.now} at the server!"
end
