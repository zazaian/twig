class Twig::FriendBox
  attr_accessor :client, :all, :active, :find, :sort_by
  def initialize(client)
    @client = client
    @active = first
  end

  def each(&block)
    all.each(&block)
  end

  # Returns the ACTIVE Twig::Friend object.
  #
  # Use :update, :sync or :refresh to rebuild the Twig::Friends.all
  # array and set the most recent friend as active.
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

  # Returns an array of all Twig::Friend objects.
  #
  # Use :update or :sync to rebuild the array with all current friends
  # from the Twitter server.
  def all(action=nil)
    
    if @all
      case action
      when :update, :sync, :refresh
        @all = @client.my(:friends).collect {|f| Twig::Friend.new(@client, f) }
      when nil
        @all
      else
        raise ArgumentError, "#{action} is not a valid argument for @all."
      end
    else
      @all = @client.my(:friends).collect {|f| Twig::Friend.new(@client, f) }
    end
  end

  
  # Returns an Array of Twig::Friend objects, sorted by the following criteria:
  #
  # _ivar_ values
  # * :id
  # * :screen_name OR :sn
  # * :time OR :created
  # * :name (user's REAL name)
  # * :favorites (total #)
  # * :statuses (total #)
  # * :followers (total #)
  # * :following (total #)
  #
  # Results can be adjusted with the following OPTIONS:
  #
  # Page Size (:page_size => Fixnum)
  # * Number of results to return per page
  # * Defaults to 10
  #
  # Page (:page => Fixnum)
  # * Page number to return
  # * Defaults to 1
  # 
  # Direction (:dir => :asc OR :desc)
  # * Direction in which to return sorted results
  # * Defaults to :desc [descending]
  #
  def sort_by(ivar=:created, opts={})
  
    ivars = {
      :id => :@id,
      :screen_name => :@screen_name,
      :sn => :@screen_name,
      :time => :@created_at,
      :created => :@created_at,
      :name => :@name,
      :favorites => :@favourites_count,
      :statuses => :@statuses_count,
      :followers => :@followers_count,
      :following => :@following
      }

    page = opts[:page] ? opts[:page] : 1
    page_size = opts[:page_size] ? opts[:page_size] : 10
    dir = opts[:dir] ? opts[:dir] : :desc

    if ! ivars[ivar]
      raise ArgumentError, "#{ivar} is not a valid argument for sort_by."
    else
      output = all.sort do |x,y|
        y.info.instance_variable_get(ivars[ivar]) <=> x.info.instance_variable_get(ivars[ivar])
      end
      output.reverse! if dir == :asc
      starts, ends = ((page_size * page) - page_size), (page_size * page)
      
      return output[starts, ends]
    end
  end
 
  # Find and return a Twig::Friend object based on user ID or screen name. 
  #
  # OPTIONS
  # 
  # ID [ :id => Fixnum ]
  # * Search for friend by ID number
  # * Must be a Fixnum object
  #
  # Screen Name [ :screen_name => String ]
  # * Search for a friend by screen name
  # * Must be a String
  #
  # Activate [ :activate => false OR true ]
  # * Determines whether or not the found friend is set as the active friend.
  # * Defaults to FALSE
  #
  # Returns nil and raises an error if no friend is found.
  #
  def find(opts={})
    id = opts[:id] ? opts[:id] : nil
    screen_name = opts[:screen_name] ? opts[:screen_name] : nil
    activate = opts[:activate] ? opts[:activate] : false

    if id || screen_name
      if id && screen_name
        output = nil
        raise ArgumentError, "Use only screen name OR id # when finding a friend."
      else
        friends = all
        if id 
          friends.each do |f|
            if f.info.id == id
              output = f
              break
            end
          end
        elsif screen_name
          friends.each do |f|
            if f.info.screen_name.downcase == screen_name.downcase
              output = f
              break
            end
          end
        end

        if output
          @active = output if activate
        else
          output = nil
          if id
            raise "Couldn't find friend ##{id}"
          else
            raise "Couldn't find friend with screen_name '#{screen_name}'"
          end
        end
      end
    else
      output = nil
      raise ArgumentError, "You must use either an id# or a screen name to find a friend."
    end

    return output
  end

  
  # Returns a Twig::Friend object with an ID or screen_name matching _friend_, and
  # sets it as the ACTIVE Twig::Friend.
  #
  # If no friend is found nil will be returned and an error will be raised.
  #
  # _friend_ can be entered as either a Twitter user ID (Fixnum), or the user's 
  # screen name (String).
  #
  def activate(friend)

    case friend
    when Fixnum
      find :id => friend, :activate => true
    when String
      find :screen_name => friend, :activate => true
    else
      return nil
      raise ArgumentError, "#{action} is not a valid argument for @activate."
    end
  end

  # Finds a Twig::Friend by _screen_name_ (String) and returns it if found,
  # otherwise returns nil and raises an error.
  #
  # Does NOT activate the Twig::Friend object if found.
  #
  def screen_name(name)
    find :screen_name => name
  end
  alias_method :sn, :screen_name

  # Finds a Twig::Friend by _id_ (Fixnum) and returns it if found, otherwise
  # returns nil and raises an error.
  #
  # Does NOT activate the Twig::Friend if found.
  #
  def id(num)
    find :id => num
  end 
 
  # Returns the first Twig::Friend object in your Twig::FriendBox.all Array
  def first
    all[0]
  end

  # Returns the last Twig::Friend object in your Twig::FriendBox.all Array
  def last
    all[all.size - 1]
  end

end



class Twig::Friend
  attr_accessor :client, :info, :timeline, :friended
  def initialize(client, info)
    @client = client
    @info = info
    @friended = true
  end

  def toggle_friend
    @friended = @friended ? false : true
  end
  protected :toggle_friend, :friended
  alias_method :toggle, :toggle_friend

  # Returns whether or not the Twig::Friend object is registered as a friend on the 
  # Twitter server: _true_ or _false_
  #
  # Twig does not contact the server to get this data.  Instead, the @friended
  # boolean is set to _true_ when the Twig::Friend object is created, and is toggled
  # between _true_ and _false_ if the Twig::Friend.befriend and
  # Twig::Friend.defriend methods are called.
  #
  def is_friend?
    @friended
  end

  # Sends a message to a Twig::Friend user.  _text_ of the message must be no more
  # than 140 characters or an _ArgumentError_ will be raised.
  #
  def message(text)
    if text.size <= 140
      @client.message(:post, text, @info)
    else
      raise ArgumentError, "Direct Messages (DMs) must be no longer than 140 characters.  " +
                           "Please trim #{text.size - 140} characters from your message " +
                           "and try again."
    end
  end

  # Returns an array of all recent status objects for the Twig::Friend user.
  #
  # If the timeline hasn't been fetched yet for the Twig::Friend user, it will be
  # fetched from the server, otherwise, the array will be called from the 
  # @timeline variable.
  #
  # The timeline can be refreshed from the server by calling timeline with the
  # :update, :refresh or :sync Symbols for _action_.
  #
  def timeline(action=nil)
    if @timeline
      case action
      when :update, :refresh, :sync
        @timeline = @client.timeline_for(:user, :id => @info.id.to_s)
      when nil
        @timeline
      else
        raise ArgumentError, "#{action} is not a valid argument for friend.timeline."
      end
    else
      @timeline = @client.timeline_for(:user, :id => @info.id.to_s)
    end
  end
  
  # Sets the Twig::Friend user as a friend on the Twitter server, and toggles the @friended
  # variable to _true_.
  #
  # If the Twig::Friend user is already set as a friend, or if Twig can't properly
  # set the user as a friend on the Twitter server, an error will be raised.
  #
  def befriend(id=nil)
    if ! @friended
      result = @client.friend(:add, @info.id)
      if result
        self.toggle
        output = result
      else
        output = nil
        raise "Unable to befriend user '#{@info.screen_name}'"
      end
    else
      output = nil
      raise ArgumentError, "'#{@info.screen_name}' is already your friend."
    end

    return output
  end

  # Removes the Twig::Friend user as a friend on the Twitter server, and toggles the @friended
  # variable to _false_.
  #
  # If the Twig::Friend user not already set as a friend, or if Twig can't properly
  # remove the user as a friend on the Twitter server, an error will be raised.
  #
  def defriend(id=nil)
    if @friended
      result = @client.friend(:remove, @info.id)
      if result
        self.toggle
        output = result
      else
        output = nil
        raise "Unable to defriend user '#{@info.screen_name}'"
      end
    else
      output = nil
      raise ArgumentError, "'#{@info.screen_name}' is not currently your friend."
    end

    return output
  end

end

module Twig::Friend::Methods
  attr_reader :friend, :friend_box
  
  # Provides access to the Twig::FriendBox object and its methods.
  #
  # When _action_ is :update, :sync, or :refresh, calling friend_box fetches
  # all friends from the Twitter server and refreshes the Twig::FriendBox
  # Array with your Twig::Friend objects.
  #
  def friend_box(action=nil)
    if @friend_box
      case action
      when :create
        @friend_box = Twig::FriendBox.new(@client)
      when :update, :sync, :refresh
        @friend_box.all :update
      when nil
        @friend_box
      else
        raise ArgumentError, "#{action} is not a valid argument for @friend."
      end
    else
      @friend_box = Twig::FriendBox.new(@client)
    end
  end
  alias_method :friends, :friend_box

  # Returns a SINGLE Twig::Friend object from the Twig::FriendBox Array.
  #
  # If _action_ is a friend's user id # (Fixnum) or a screen name (String), the 
  # corresponding user will be searched for in the Twig::FriendBox Array.  If the
  # Twig::Friend object is found, it will be returned, otherwise _nil_ will be
  # returned and an error will be raised.
  #
  # If _action_ is :active, or left empty, _friend_ will return the ACTIVE
  # Twig::Friend object in Twig::FriendBox.active.  If no Twig::Friend has been
  # made active, _nil_ will be returned.
  #
  def friend(action=nil)
    case action 
    when Fixnum
      friend_box.id(action)
    when String
      friend_box.sn(action)
    when nil, :active
      friend_box.active
    end
  end
end

