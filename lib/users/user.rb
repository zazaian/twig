
class Twirp::User
  attr_accessor :login, :password, :client,
                :info, :friends, :followers, :favorites,
                :statuses, :messages, :timelines
  
  Options = [:login, :pass]
  def initialize (opts={})
    include CheckOpts
    check_opts
    
    @client = Twitter::Client.new(:login => @login, :password => @password)

  end


  def message(opt={})
    @messages << Message.new(self, opt)
  end
