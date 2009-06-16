#!/usr/bin/ruby

$LOAD_PATH << Dir.glob("**/")
# Require the Twitter4r Gem
require 'rubygems'
gem 'twitter4r', '>=0.2.4'
require 'twitter'

# Require helper files
require 'commands'
require 'version'
require 'action'

class Twirp
  attr_accessor :options, :login, :password, :client,
                :info, :friends, :followers, :favorites,
                :status, :status_box, :message, :message_box,
                :timelines, :history

  ValidOpts = [:login, :password]
  def initialize(opts={})
    # Check options passed into a new Twerp
    include CheckOpts
    check_opts
    
    # Parse options from ARGV
    @options = Options.parse(ARGV)
    @login = opts[:login] ? opts[:login] : @options.login
    @password = opts[:password] ? opts[:password] : @options.password
   
    @client = Twitter::Client.new(:login => @login, :password => @password)
    @user = Twitter::User.new(@login)

    update
  end

  def update
    @message_box = Twirp::MessageBox.new(@client)
    @status = Twirp::Status.new(@client)
    
    @info = @client.my(:info)
    @friends = @client.my(:friends)
    @followers = @info.followers
    @favorites = @client.favorites
  end

end

t = Twirp.new
