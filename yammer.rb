#!/usr/bin/env ruby

require 'optparse'
require 'yammer'
require 'rainbow'
require 'date'
require 'oauth'
require 'yaml'
require 'pry'

CONSUMER_TOKEN = 'mWn3PY7sc2znsuZxEMvNUQ'
CONSUMER_SECRET = 'AGP2akBsMwybb1AoGBp7RdLc4vfb2l3NY4P6VM'

options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: yammer.rb [options] ..."

  options[:update] = false
  opts.on( '-u', '--update', 'Send an update to yammer' ) do
    options[:update] = true
  end
 
  options[:list] = false
  opts.on( '-l', '--list', 'Get the last 20 updates' ) do
    options[:list] = true
  end
  
  options[:setup] = false
  opts.on( '-s', '--setup', 'Setup OAuth authentication to Yammer' ) do
    options[:setup] = true
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

#parse command line arguments and remove parsed flags from ARGV
optparse.parse!
 
#search users for user with specific id and return that user
def get_user(users, id)
  user = users.select { |f| f[:id] == id }
  user.first
end

settings_path = File.expand_path('~/Dropbox/Development/Ruby/yammer-cli/config.yml')

if File.exists?(settings_path)
  settings = YAML::load(File.open(settings_path))
  #binding.pry
else
  #settings = { :consumer_key => 'mWn3PY7sc2znsuZxEMvNUQ', :consumer_secret => 'AGP2akBsMwybb1AoGBp7RdLc4vfb2l3NY4P6VM', :oauth_token => 'ZgBliu20ToeIho4Ny4nUcA', :oauth_secret => 'TQ6ppWF3CjeY6ccCFPUvz1N5BLbGjEoXf1jvocFm4k'}
  p "settings not found."
end


# 
# File.open('config.yml', "w") do |f|
#   f.write(settings.to_yaml)
# end


#configure the yammer authentication parameters
Yammer.configure do |config|
  config.consumer_key = CONSUMER_TOKEN
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = settings[:oauth_token]
  config.oauth_token_secret = settings[:oauth_secret]
end

#create new yammer object
yammer = Yammer.new

if options[:update]
  update = ARGV.join(' ')
  puts "Sending update to Yammer: #{update}"
  yammer.update(update)
end

if options[:list]
  messages = yammer.messages
  
  #parse out user objects from references
  users = messages[:references].select {|f| f[:type] == 'user' }
  
  #parse each message and look up user names from users array
  messages[:messages].each do |message|
    body = message[:body][:plain]
    created_at = DateTime.parse(message[:created_at]).to_time.getlocal.strftime("%I:%M%p")
    user = get_user(users, message[:sender_id])[:full_name]
    puts user.foreground(:red) + " at " + created_at.foreground(:blue) + " " + body
  end
end

if options[:setup]
  
  consumer=OAuth::Consumer.new CONSUMER_TOKEN, 
                                CONSUMER_SECRET, 
                                {:site=>"https://www.yammer.com"}

  request_token=consumer.get_request_token

  puts "Place \"#{request_token.authorize_url}\" in your browser"
  print "Enter the number they give you: "
  pin = STDIN.readline.chomp

  access_token = request_token.get_access_token(:oauth_verifier => pin)

  puts "Token: #{access_token.token}"

  puts "Secret: #{access_token.secret}"
  
end

