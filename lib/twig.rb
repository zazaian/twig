
# YOU ARE THE TWIG

# Load all sub-directories recursively as load paths
Dir.glob("**/").each {|d| $LOAD_PATH << d}

# Require the Twitter4r Gem
require 'rubygems'
gem 'twitter4r', '>=0.2.4'
require 'twitter'

# Require helper files
require 'message'
require 'status'
require 'user'
require 'version'

class Twig
  attr_accessor :login, :password, :client,
                :info, :friends, :followers, :favorites,
                :status, :timelines, :message, :message_box
 
  def initialize(opts={}) 
    @login = opts[:login] ? opts[:login] : "zazaian" #@options.login
    @password = opts[:password] ? opts[:password] : "Mistered1" #@options.password
   
    @client = Twitter::Client.new(:login => @login, :password => @password)
  end

  include Twig::Status::Methods
  # Access to the status object

  include Twig::MessageBox::Methods 
  # MessageBox, update, sent, received, inbox, outbox    
  
  include Twig::User
  # info, friends, favorites, followers

end
