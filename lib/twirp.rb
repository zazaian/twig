
Dir.glob("**/").each {|d| $LOAD_PATH << d}
# Require the Twitter4r Gem
require 'rubygems'
gem 'twitter4r', '>=0.2.4'
require 'twitter'

# Require helper files
require 'commands'

class Twirp
  attr_accessor :options, :login, :password, :client,
                :info, :friends, :followers, :favorites,
                :status, :status_box, :message, :message_box,
                :timelines, :history
 
  def initialize(opts={}) 
    # Parse options from ARGV
    @login = opts[:login] ? opts[:login] : "zazaian" #@options.login
    @password = opts[:password] ? opts[:password] : "Mistered1" #@options.password
   
    @client = Twitter::Client.new(:login => @login, :password => @password)
    @user = Twitter::User.new(@login)
    
    @message_box = Twirp::MessageBox.new(@client)
    @status = Twirp::Status.new(@client)

    #update :status => false, :message => false
  end

  def update(opts={})
    message = opts[:message] ? opts[:message] : true
    status = opts[:status] ? opts[:status] : true
    
    @message_box.update if message
    @status.update if status
    
    @info = @client.my(:info)
    @friends = @client.my(:friends)
    @followers = @client.my(:followers)
    @favorites = @client.favorites
  end

  def inbox
    @message_box.received
  end

  def outbox
    @message_box.sent
  end

  def received
    inbox
  end

  def sent
    outbox
  end
    

end
require 'version'
require 'action'
require 'ago'
