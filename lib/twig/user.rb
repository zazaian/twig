
class Twig::Users
  attr_accessor :client, :active, :fetched
  def initialize(client)
    @client = client
  end

  def first
    if fetched.size > 0
      # Find the first object sorted by id
      fetched[fetched.sort {|a,b| a[1] <=> b[1]}[0][0]]
    else
      nil
    end
  end 

  def fetched(action=nil)
    if @fetched
      case action
      when :clear
        @fetched = {}
      when nil
        @fetched
      else
        raise ArgumentError, "#{action} is not a valid argument for @fetched."
      end
    else
      @fetched = {}
    end
  end
  alias_method :all, :fetched

  
  def find(id_sn, action=nil)
    unless [String, Fixnum, Twitter::User].member?(id_sn.class)
      raise "User must be inputted as either a screen_name(String), a user id#(Fixnum)," \
          + " or a Twitter::User object."
    else
      case id_sn
      when Fixnum
        if @fetched[id_sn]
          @active = fetched[id_sn]
          output = @active
        else
          user_check = @client.user(id_sn)
          if user_check
            id = user_check.id
            fetched[id] = Twig::User.new(@client, user_check)
            @active = fetched[id]
            output = @active
          else
            output = nil
            raise "Twitter user ##{id} could not be found."
          end
        end
      when String
        match = nil
        #sort through fetched users
        fetched.each do |user_id, user_obj|
          if user_obj.info.screen_name == id_sn
            match = fetched[user_obj.info.id]
            break
          end
        end

        if match
          @active = match
          output = @active
        else
          user_check = @client.user(id_sn)
          if user_check
            id = user_check.id
            fetched[id] = Twig::User.new(@client, user_check)
            @active = fetched[id]
            output = @active
          else
            output = nil
            raise "Twitter user '#{user}' could not be found."
          end
        end
      when Twitter::User
        if fetched[id_sn.id]
          @active = fetched[id_sn.id]
          output = @active
        else
          user_check = @client.user(id_sn.id)
          if user_check
            id = user_check.id
            fetched[id] = Twig::User.new(@client, user_check)
            @active = fetched[id]
            output = @active
          else
            output = nil
            raise "Twitter user ##{user} could not be found."
          end
        end
      end
    end

    return output
  end
  alias_method :screen_name, :find
  alias_method :sn, :find
  alias_method :id, :find
 
end

class Twig::User
  attr_accessor :client, :info, :timeline
  def initialize(client, user)
    @client = client
    @info = user
  end
  
  def timeline(action=nil)
    if @timeline
      case action
      when :update
        @timeline = @client.timeline_for(:user, :id => @info.id)
      when nil
        @timeline
      else
        raise ArgumentError, "#{action} is not a valid argument for @timeline."
      end
    else
      @timeline = @client.timeline_for(:user, :id => @info.id)
    end
  end

  def status
    timeline[0]
  end

  def message(text)
    if text.size > 140
      raise ArgumentError, "Message cannot be longer than 140 characters.  Please trim " \
                         + "#{text.size - 140} characters from the message and try again."
    else
      @client.message(:post, text, @info.id)
    end
  end

  def befriend
    result = @client.friend(:add, @info)
    if result
      output = result
    else
      output = nil
      raise "Unable to befriend user '#{@info.screen_name}'"
    end

    return output
  end

  def defriend
    result = @client.friend(:remove, @info)
    if result
      output = result
    else
      output = nil
      raise "Unable to defriend user '#{@info.screen_name}'"
    end

    return output
  end
end

module Twig::Users::Methods
  attr_reader :users
  
  def users(action=nil)
    if @users
      case action
      when :clear
        @users = Twig::Users.new(@client)
      when nil
        @users
      else
        raise ArgumentError, "#{action} is not a valid argument for @users."
      end
    else
      @users = Twig::Users.new(@client)
    end
  end

  def user(id_sn=nil)
    case id_sn
    when nil
      users.active
    else
      users.find(id_sn)
    end
  end
end
