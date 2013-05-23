require 'yammer'
require 'rainbow'
require 'launchy'
require 'date'
require 'oauth'
require 'yaml'

class YammerCli

  def self.new
    super
  end

  def initialize

    @config_file_path = File.dirname(__FILE__) + '/config.yml'
    @required_settings = [:consumer_token, :consumer_secret, :oauth_token, :oauth_secret]

    if valid_config?
      settings = YAML::load(File.open(@config_file_path))
    else
      exit
    end

    #configure the yammer authentication parameters
    Yammer.configure do |config|
      config.consumer_key = settings[:consumer_token]
      config.consumer_secret = settings[:consumer_secret]
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

    current_date = ""

    #parse each message and look up user names from users array
    messages[:messages].each do |message|
      body = message[:body][:plain]
      created_at = DateTime.parse(message[:created_at])
      date = get_date(created_at.to_date)
      user = get_user(users, message[:sender_id])[:full_name]

      # write out current date
      if date != current_date
        puts " --- #{date} ---".foreground(:yellow)
        current_date = date
      end

      puts user.foreground(:red) + " at " + created_at.to_time.getlocal.strftime("%I:%M%p").foreground(:blue) + " " + body
    end
  end

  def self.setup(consumer_token, consumer_secret)
    consumer=OAuth::Consumer.new consumer_token,
      consumer_secret, 
      {:site=>"https://www.yammer.com"}

    request_token=consumer.get_request_token

    Launchy.open(request_token.authorize_url)

    print "Enter the code from the Yammer website: "
    pin = STDIN.readline.chomp

    access_token = request_token.get_access_token(:oauth_verifier => pin)

    tokens = {:oauth_token => access_token.token, :oauth_secret => access_token.secret, :consumer_token => consumer_token, :consumer_secret => consumer_secret}

    config_file_path = File.dirname(__FILE__) + '/config.yml'
    File.open(config_file_path, "w") do |f|
      f.write tokens.to_yaml
    end

    puts "Settings saved."

  end

  def valid_config?

    valid_config = true
    if File.exists?(@config_file_path)
      settings = YAML::load(File.open(@config_file_path))
      @required_settings.each do |required_setting|
        if settings[required_setting] == nil
          valid_config = false
        end
      end
    else
      valid_config = false
    end
    
    if !valid_config
      puts "Settings not valid. Run yammer with --setup (-s) option with your yammer Consumer Token and Consumer Secret."
      puts "If you have not registered the app you can do so here https://developer.yammer.com/introduction/"
      puts "to receive your Consumer Token and Consumer Secret."
    end

    valid_config

  end

  #search users for user with specific id and return that user
  def get_user(users, id)
    user = users.select { |f| f[:id] == id }
    user.first
  end

  # return either Today or formatted date
  def get_date(date)
    date == Date.today ? "Today" : date.strftime("%A, %B %e %Y")
  end


end
