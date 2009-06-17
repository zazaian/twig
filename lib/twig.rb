
# YOU ARE THE TWIG

# Load all sub-directories recursively as load paths
Dir.glob("**/").each {|d| $LOAD_PATH << d}

# Require the Twitter4r Gem
require 'rubygems'
gem 'twitter4r', '>=0.2.4'
require 'twitter'

# Require helper files
require 'message_box'
require 'status'
require 'friend'
require 'user'
require 'version'
#require 'ago'

class Twig
  attr_reader :login, :password, :client, :timelines, :message
 
  def initialize(opts={}) 
    @login = opts[:login] ? opts[:login] : "zazaian" #@options.login
    @password = opts[:password] ? opts[:password] : "Mistered1" #@options.password
   
    @client = Twitter::Client.new(:login => @login, :password => @password)
  end

  include Twig::Status::Methods
  # Access to the Status object

  include Twig::MessageBox::Methods 
  # MessageBox, update, sent, received, inbox, outbox
  
  include Twig::Friend::Methods
  # Access to the Friend object
  
  include Twig::User
  # info, favorites, followers

end
