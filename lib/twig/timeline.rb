
class Twig::Timelines
  attr_reader :client, :mine, :friends, :public, :user
  def initialize(client)
    @client = client
  end

  def mine(action=nil)
    if @mine
      case action
      when :update
        @mine = Twig::Timeline::Mine.new(@client)
      when nil
        @mine
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @mine = Twig::Timeline::Mine.new(@client)
    end
  end
  alias_method :my, :mine

  def friends(action=nil)
    if @friends
      case action
      when :update
        @friends = Twig::Timeline::Friends.new(@client)
      when nil
        @friends
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @friends = Twig::Timeline::Friends.new(@client)
    end
  end

  def public(action=nil)
    if @public
      case action
      when :update
        @public = Twig::Timeline::Public.new(@client)
      when nil
        @public
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @public = Twig::Timeline::Public.new(@client)
    end
  end

  def user(id_sn, action=nil)
    unless [String, Fixnum, Twitter::User].member?(user.class)
      raise "User must be inputted as either a screen_name(String), a user id#(Fixnum)," \
          + " or a Twitter::User object."
    else
      if @user[id_sn]
        id = id_sn
      else
        user_check = @client.user(user)
        if user_check
          id = user_check.id
        else
          raise "Twitter user '#{user}' could not be found."
        end
      end
    end
    
    if @user
      case action
      when :update
        @user = {}
        @user[id] = Twig::Timeline::User.new(@client, user_check)
      when nil
        @user
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @user = {}
      @user[id] = Twig::Timeline::User.new(@client, user_check)
    end
  end

end

class Twig::Timeline
  attr_reader :client, :statuses
  def initialize(client)
    @client = client
  end

  def statuses(action=nil)
    if @statuses
      case action
      when :update
        @statuses = fill
      when nil
        @statuses
      else
        raise ArgumentError, "#{action} is not a valid argument for @statuses."
      end
    else
      @statuses = fill
    end
  end
  alias_method :print, :statuses
  alias_method :all, :statuses

  
  def sort_by(ivar, opts={})

    stat_vars = {
      :id => :@id,
      :created => :@created_at,
      :text => :text
      }

    user_vars = {
      :screen_name => :@screen_name,
      :user_id => :@id,
      :user_name => :@name
    }

    user = self.class == Twig::Inbox ? :@sender : :@recipient

    page = opts[:page] ? opts[:page] : 1
    page_size = opts[:page_size] ? opts[:page_size] : 10
    dir = opts[:dir] ? opts[:dir] : :desc

    if ! stat_vars[ivar] && ! user_vars[ivar]
      raise ArgumentError, "#{ivar} is not a valid argument for sort_by."
    else
      output = statuses.sort do |x,y|
        if stat_vars[ivar]
          y.instance_variable_get(stat_vars[ivar]) <=> \
            x.instance_variable_get(stat_vars[ivar])
        else
          y.user.instance_variable_get(user_vars[ivar]) <=> \
            x.user.instance_variable_get(user_vars[ivar])
        end
      end
      
      output.reverse! if dir == :asc
      starts, ends = ((page_size * page) - page_size), (page_size * page)
      
      return output[starts, ends]
    end
  end

end

class Twig::Timeline::Public < Twig::Timeline
  def fill
    @client.timeline_for(:public)
  end
end

class Twig::Timeline::Friends < Twig::Timeline
  def fill
    @client.timeline_for(:friends)
  end
end

class Twig::Timeline::Mine < Twig::Timeline
  def fill
    @client.timeline_for(:me)
  end
end

class Twig::Timeline::User < Twig::Timeline
  attr_reader :client, :user, :statuses
  def initialize(client, user)
    @client = client
    @user = user
  end
  
  def fill
    @client.timeline_for(:user, @user.id)
  end
end

module Twig::Timelines::Methods
  attr_reader :timelines
  def timelines(action=nil)
    if @timelines
      case action
      when :update
        @timelines = Twig::Timelines.new(@client)
      when nil
        @timelines
      else
        raise ArgumentError
      end
    else
      @timelines = Twig::Timelines.new(@client)
    end
  end
end
