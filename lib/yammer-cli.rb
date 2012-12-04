require 'yammer'
require 'rainbow'
require 'launchy'
require 'date'
require 'oauth'
require 'yaml'

class YammerCli

  #attr_accessor :yammer

  CONSUMER_TOKEN = 'mWn3PY7sc2znsuZxEMvNUQ'
  CONSUMER_SECRET = 'AGP2akBsMwybb1AoGBp7RdLc4vfb2l3NY4P6VM'

  def self.new
    super
  end

  def initialize

    settings_path = File.dirname(__FILE__) + '/config.yml'

    if File.exists?(settings_path)
      settings = YAML::load(File.open(settings_path))
    else
      puts "Settings not found. Run yammer with --setup (-s) option."
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

  def send_update(update, params)
      puts "Sending update to Yammer: #{update}"
      @yammer.update(update, params)
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

  def self.setup
    consumer=OAuth::Consumer.new CONSUMER_TOKEN,
      CONSUMER_SECRET, 
      {:site=>"https://www.yammer.com"}

    request_token=consumer.get_request_token

    Launchy.open(request_token.authorize_url)

    print "Enter the code from the Yammer website: "
    pin = STDIN.readline.chomp

    access_token = request_token.get_access_token(:oauth_verifier => pin)

    tokens = {:oauth_token => access_token.token, :oauth_secret => access_token.secret}

    settings_path = File.dirname(__FILE__) + '/config.yml'

    File.open(settings_path, "w") do |f|
      f.write tokens.to_yaml
    end

    puts "Settings saved."

  end


  #search users for user with specific id and return that user
  def get_user(users, id)
    user = users.select { |f| f[:id] == id }
    user.first
  end


end
