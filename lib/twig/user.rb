
class Twig::Users
  attr_reader :fetched
  def initialize(client)
    @client = client
  end
  
  def active(action=nil)
    if @active
      case action
      when :update
        @active = first
      when nil
        @active
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @active = first
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
    unless [String, Fixnum, Twitter::User].member?(user.class)
      raise "User must be inputted as either a screen_name(String), a user id#(Fixnum)," \
          + " or a Twitter::User object."
    else
      case id_sn
      when Fixnum
        if @fetched[id_sn]
          @active = @fetched[id_sn]
          output = @active
        else
          user_check = @client.user(id_sn)
          if user_check
            id = user_check.id
            @fetched[id] = user_check
            @active = @fetched[id]
            output = @active
          else
            output = nil
            raise "Twitter user ##{id} could not be found."
          end
        end
      when String
        @fetched.each do |u|
          if u.screen_name == id_sn
            match = @fetched[u.id]
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
            @fetched[id] = user_check
            @active = @fetched[id]
            output = @active
          else
            output = nil
            raise "Twitter user '#{user}' could not be found."
          end
        end
      when Twitter::User
        if @fetched[id_sn.id]
          @active = @fetched[id_sn.id]
          output = @active
        else
          user_check = @client.user(id_sn.id)
          if user_check
            id = user_check.id
            @fetched[id] = user_check
            @active = @fetched[id]
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
 
  def first
    fetched[0]
  end

  def last
    fetched[fetched.size - 1]
  end
end

class Twig::User
  attr_accessor :client
  def initialize(client)
    @client = client
  end
end

module Twig::Users::Methods
  attr_reader :users
  @user = Twig::Users.new(@client)

  def user(id_sn)
    @user.fetched[id_sn]
  end
end
