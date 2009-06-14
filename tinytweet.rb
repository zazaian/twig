#!/usr/bin/ruby

$LOAD_PATH << Dir.glob("**/")
# Require the Twitter4r Gem
require 'rubygems'
gem 'twitter4r', '>=0.2.0'
require 'twitter'

# Require helper files
require 'options'
require 'version'

class TinyTweet
  attr_accessor :options, :client
  def initialize()
    # Parse options from ARGV
    @options = Options.parse(ARGV)
    @client = Twitter::Client.new(:login => @options.login, :password => @options.password)
  end

  # Login Info 

  if aargvark.matches.index("-p")
    puts "### PUBLIC MESSAGES ###"
    public_timeline = client.timeline_for(:public) do |status|
      # do something here with each individual status in timeline that is also returned
      
      puts status.text
    end
  end
end
