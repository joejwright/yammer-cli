#!/usr/bin/env ruby

require 'optparse'
require 'yammer'
require 'rainbow'
require 'date'
require 'pry'

options = {}

optparse = OptionParser.new do|opts|
 # Set a banner, displayed at the top
 # of the help screen.
 opts.banner = "Usage: yammer.rb [options] ..."

 # Define the options, and what they do
 options[:update] = false
 opts.on( '-u', '--update', 'Send an update to yammer' ) do
   options[:update] = true
 end
 
 options[:list] = false
 opts.on( '-l', '--list', 'Get the last 20 updates' ) do
   options[:list] = true
 end

# options[:logfile] = nil
# opts.on( '-l', '--logfile FILE', 'Write log to FILE' ) do|file|
#   options[:logfile] = file
# end

 # This displays the help screen, all programs are
 # assumed to have this option.
 opts.on( '-h', '--help', 'Display this screen' ) do
   puts opts
   exit
 end
end
 
 # Parse the command-line. Remember there are two forms
 # of the parse method. The 'parse' method simply parses
 # ARGV, while the 'parse!' method parses ARGV and removes
 # any options found there, as well as any parameters for
 # the options. What's left is the list of files to resize.
 optparse.parse!
 
#some simple functions
def get_user(users, id)
  # user = users.select { |f| f['id'] == id }
  # user.first
  
  users.each do |u|
    if u[:id] == id
      return u
    end
  end
  
end


Yammer.configure do |config|
    config.consumer_key = 'mWn3PY7sc2znsuZxEMvNUQ'
    config.consumer_secret = 'AGP2akBsMwybb1AoGBp7RdLc4vfb2l3NY4P6VM'
    config.oauth_token = 'ZgBliu20ToeIho4Ny4nUcA'
    config.oauth_token_secret = 'TQ6ppWF3CjeY6ccCFPUvz1N5BLbGjEoXf1jvocFm4k'
  end
  #Yammer.update("This is an update from the Yammer gem")
  # If you have the thread id you want to retrieve 
  #thread = Yammer.thread(thread_id)
  # retrieve the most recent 20 messages
  # messages = Yammer.messages

yammer = Yammer.new

if options[:update]
  update = ARGV.join(' ')
  puts "Sending update to Yammer: #{update}"
  yammer.update(update)
end

if options[:list]
  messages = yammer.messages
  
  users = messages[:references].select {|f| f['type'] == 'user' }
  # messages[:references].each do |reference|
  #   puts reference[:type]
  # end
  
  messages[:messages].each do |message|
    body = message[:body][:plain]
    created_at = DateTime.parse(message[:created_at]).to_time.getlocal.strftime("%I:%M%p")
    user = get_user(users, message[:sender_id])[:full_name]
    puts user.foreground(:red) + " at " + created_at.foreground(:blue) + " " + body
    #puts "#{user} at #{created_at}  #{body}"
  end
  
  #binding.pry
end



#binding.pry  
