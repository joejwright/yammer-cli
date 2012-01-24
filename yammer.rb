#!/usr/bin/env ruby

require 'optparse'
require 'yammer'
require 'rainbow'
require 'date'
require 'pry'

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

#configure the yammer authentication parameters
Yammer.configure do |config|
  config.consumer_key = ''
  config.consumer_secret = ''
  config.oauth_token = ''
  config.oauth_token_secret = ''
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

