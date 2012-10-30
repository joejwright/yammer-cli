require 'yammer'
require 'rainbow'
require 'date'
require 'oauth'
require 'yaml'
require 'pry'

class YammerCli

  #attr_accessor :yammer

  CONSUMER_TOKEN = 'mWn3PY7sc2znsuZxEMvNUQ'
  CONSUMER_SECRET = 'AGP2akBsMwybb1AoGBp7RdLc4vfb2l3NY4P6VM'

  def initialize

    settings_path = File.expand_path('./lib/config.yml')

    if File.exists?(settings_path)
      settings = YAML::load(File.open(settings_path))
    else
      puts "Settings not found. Run yammer with config option."
      exit
    end

    #configure the yammer authentication parameters
    Yammer.configure do |config|
      config.consumer_key = CONSUMER_TOKEN
      config.consumer_secret = CONSUMER_SECRET
      config.oauth_token = settings[:oauth_token]
      config.oauth_token_secret = settings[:oauth_secret]
    end

    #create new yammer object
    @yammer = Yammer.new

  end

  def send_update(update)
      puts "Sending update to Yammer: #{update}"
      @yammer.update(update)
  end

  def list
    messages = @yammer.messages

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

  def setup
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


  #search users for user with specific id and return that user
  def get_user(users, id)
    user = users.select { |f| f[:id] == id }
    user.first
  end



  if options[:setup]



  end

end
