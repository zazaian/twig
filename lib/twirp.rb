
Dir.glob("**/").each {|d| $LOAD_PATH << d}
# Require the Twitter4r Gem
require 'rubygems'
gem 'twitter4r', '>=0.2.4'
require 'twitter'

# Require helper files
require 'commands'

class Twirp
  attr_accessor :options, :login, :password, :client, :user,
                :info, :friends, :followers, :favorites,
                :status, :status_box, :message, :message_box,
                :timelines, :history
 
  def initialize(opts={}) 
    # Parse options from ARGV
    @login = opts[:login] ? opts[:login] : "zazaian" #@options.login
    @password = opts[:password] ? opts[:password] : "Mistered1" #@options.password
   
    @client = Twitter::Client.new(:login => @login, :password => @password)
    @user = Twitter::User.new(@login)
  end

  def status(action=nil)
    if @status
      case action
      when :create
        @status = Twirp::Status.new(@client)
      when :update
        @status.update
      when nil
        @status
      else
        raise ArgumentError, "#{action} is not a valid argument for @status."
      end
    else
      @status = Twirp::Status.new(@client)
    end
  end

  def message_box(action=nil)
    if @message_box
      case action
      when :create
        @message_box = Twirp::MessageBox.new(@client)
      when :update
        @message_box.update
      when nil
        @message_box
      else
        raise ArgumentError
      end
    else
      @message_box = Twirp::MessageBox.new(@client)
    end
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

    
  def info(action=nil)
    if @info
      case action
      when :update
        @info = @client.my(:info)
      when nil
        @info
      else
        raise ArgumentError, "#{action} is not a valid argument for @info."
      end
    else
      @info = @client.my(:info)
    end
  end

  def friends(action=nil)
    if @friends
      case action
      when :update
        @friends = @client.my(:friends)
      when nil
        @friends
      else
        raise ArgumentError, "#{action} is not a valid argument for @friends."
      end
    else
      @friends = @client.my(:friends)
    end
  end

  def followers(action=nil)
    if @followers
      case action
      when :update
        @followers = @client.my(:followers)
      when nil
        @followers
      else
        raise ArgumentError, "#{action} is not a valid argument for @followers."
      end
    else
      @followers = @client.my(:followers)
    end
  end

  def favorites(action=nil)
    if @favorites
      case action
      when :update
        @favorites = @client.favorites
      when nil
        @favorites
      else
        raise ArgumentError, "#{action} is not a valid argument for @favorites."
      end
    else
      @favorites = @client.favorites
    end
  end


end
require 'version'
require 'action'
require 'ago'
