
class Twig::Users
  attr_accessor :client, :active, :fetched
  def initialize(client)
    @client = client
  end

  # Returns the first Twig::User object in the Twig::Users.fetched Hash based
  # on the Twig::User.info.id #.
  #
  def first
    if fetched.size > 0
      # Find the first object sorted by id
      fetched[fetched.sort {|a,b| a[1] <=> b[1]}[0][0]]
    else
      nil
    end
  end

  # Returns a Hash of all Twig::User objects that have been fetched from the
  # Twitter server in the format _id #_ => Twig::User.
  #
  # If _fetched_ has not been called before, or if _action_ is :clear, :empty or
  # :destroy, it will be reset to an empty Hash object.
  #
  def fetched(action=nil)
    if @fetched
      case action
      when :clear, :empty, :destroy
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

  # Returns the _active_ Twig::User in the Twig::Users object.
  #
  # If active hasn't been called before, or if _action_ is :update, :sync, or
  # :refresh, the Twig::User object with the numerically smallest id # in the
  # Twig::Users.fetched Hash will be returned.
  #
  # If there are no Twig::User objects in the _fetched_ Hash, _nil_ will be
  # returned.
  #
  def active(action=nil)
    if @active
      case action
      when :update, :sync, :refresh
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
 
  # Searches for a Twig::User object by _id_sn_ (either Fixnum id # or String
  # screen_name), and returns the Twig::User object if found.
  #
  # _find_ first searches through the _fetched_ hash for the Twig::User, to check whether
  # it's already been fetched from the Twitter server.
  #
  # If found in _fetched_ the Twig::User object will be returned.  If not found
  # in _fetched_, _find_ will query the Twitter server to check whether a user
  # exists with the provided _id_sn_.  If no user is found on the server, _nil_ will
  # be returned and an _error_ will be raised.
  # 
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

  # Returns an Array of all recent Twig::Status objects for the Twig::User.
  #
  # If _timeline_ hasn't been called before, or if _action_ is :update, :sync, or
  # :refresh, _timeline_ will refresh itself with current Twig::Status objects
  # from the Twitter server.
  #
  def timeline(action=nil)
    if @timeline
      case action
      when :update, :sync, :refresh
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

  # Returns the active Twig::Status for the Twig::User.  If the user has no _status_
  # objects associated with it, _nil_ will be returned.
  #
  def status
    timeline[0]
  end
  
  # Direct Messages _text_ to the user.
  #
  # If successful, returns the Twitter::Message object.  If the message can't be
  # sent, or if _text_ is greater than 140 characters, _nil_ will be returned and 
  # an error will be raised.
  #
  def message(text)
    if text.size > 140
      return nil
      raise ArgumentError, "Message cannot be longer than 140 characters.  Please trim " \
                         + "#{text.size - 140} characters from the message and try again."
    else
      @client.message(:post, text, @info.id)
    end
  end

  # Attempts to add the Twig::User as a friend.
  #
  # If successful, _befriend_ returns the friended Twig::User.  If the user is not
  # successfully friended, or if the Twig::User is already a friend, _nil_ will be
  # returned and an error will be raised.
  #
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

  # Attempts to remote the Twig::User as a friend.
  #
  # If successful, _defriend_ returns the de-friended Twig::User.  If the user is not
  # successfully defriended, or if the Twig::User is not currently a friend, _nil_ will be
  # returned and an error will be raised.
  #
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
 
  # Provides access to the Twig::Users object.
  #
  # If users hasn't been called yet, or if _action_ is :clear, :empty  or :destroy,
  # a new Twig::Users object will be instantiated and all Twig::Users objects in the
  # _fetched_ Hash will be deleted.
  #
  def users(action=nil)
    if @users
      case action
      when :clear, :destroy, :empty
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

  # Provides direct access to the _find_ method of the Twig::Users object.
  #
  # If. _id_sn_ is provided, _user_ will attempt to _find_ the Twig::User with
  # the corresponding Fixnum _id_ # or String _screen_name_, first in the Twig::Users
  # _fetched_ Hash, then on the Twitter server
  #
  # if _id_sn_ is _nil_ or left empty, _user_ will return the active Twig::User
  # in the Twig::Users object.
  #
  def user(id_sn=nil)
    case id_sn
    when nil
      users.active
    else
      users.find(id_sn)
    end
  end
end
