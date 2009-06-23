
class Twig::Timelines
  attr_reader :client, :mine, :friends, :public, :user
  def initialize(client)
    @client = client
  end


  # Returns an Array of all recent Twig::Status objects for the Twig::My user.
  # If _action_ is :empty, :clear or :destroy, the Twig::Timeline::Mine object
  # will be re-instantiated, and all fetched Twig::Status objects will be 
  # cleared from the box.
  #
  def mine(action=nil)
    if @mine
      case action
      when :empty, :clear, :destroy
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

  # Returns an Array of all recent Twig::Status objects for friends of the
  # Twig::My user.  If _action_ is :empty, :clear or :destroy, the
  # Twig::Timeline::Friends object will be re-instantiated, and all fetched
  # Twig::Status objects will be cleared from the box.
  #
  def friends(action=nil)
    if @friends
      case action
      when :empty, :clear, :destroy
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

  # Returns an Array of all recent Twig::Status objects from the public Twitter
  # timeline.  If _action_ is :empty, :clear or :destroy, the Twig::Timeline::Public
  # object will be re-instantiated, and all fetched Twig::Status objects will
  # be cleared from the box.
  #
  def public(action=nil)
    if @public
      case action
      when :empty, :clear, :destroy
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

end

class Twig::Timeline
  attr_reader :client, :statuses
  def initialize(client)
    @client = client
  end

  # Returns an Array of all Twig::Status objects found for the given timeline.
  # 
  # If statuses is called for the first time, or if _action_ is :update, :sync
  # or :refresh, it will _fill_ itself with all recent Twig::Status objects
  # from the Twitter server.
  #
  def statuses(action=nil)
    if @statuses
      case action
      when :update, :sync, :refresh
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

  
  # Returns an Array of Twig::Status objects for the selected Twig::Timeline
  # object, sorted by the following criteria:
  #
  # _ivar_ can be either an aspect of the Twig::Status objects being searched for,
  # or the Twig::User objects that own the given statuses:
  #
  # STATUS _ivars_
  # * :id OR :msg_id
  # * :created OR :date
  # * :text
  #
  # USER _ivars_
  # * :screen_name OR :sn
  # * :user_id OR :uid
  # * :name OR :user_name OR :real_name
  #
  # Results can also be adjusted with the following _OPTIONS_:
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

    stat_vars = {
      :id => :@id,
      :status_id => :@id,
      :created => :@created_at,
      :date => :@created_at,
      :text => :text
      }

    user_vars = {
      :screen_name => :@screen_name,
      :sn => :@screen_name,
      :user_id => :@id,
      :uid => :@id,
      :name => :@name,
      :user_name => :@name,
      :real_name => :@name
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

  # Fills the Twig::Timeline::Public object with all recent Twig::Status
  # objects for the public from the Twitter server.
  #
  def fill
    @client.timeline_for(:public)
  end
end

class Twig::Timeline::Friends < Twig::Timeline
  # Fills the Twig::Timeline::Friends object with all recent Twig::Status
  # objects for friends on the Twitter server.
  #
  def fill
    @client.timeline_for(:friends)
  end
end

class Twig::Timeline::Mine < Twig::Timeline
  # Fills the Twig::Timeline::Mine object with all recent Twig::Status
  # objects for the Twig::My user on the Twitter server.
  #
  def fill
    @client.timeline_for(:me)
  end
end

module Twig::Timelines::Methods
  attr_reader :timelines

  # Provides access to the Twig::Timeline objects for the user.
  #
  # If _action_ is :empty, :clear or :destroy, the Twig::Timelines object
  # will be re-instantiated, and all fetched Twig::Status objects for the
  # _public_, _friends_ and _mine_ timelines will be cleared.
  #
  def timelines(action=nil)
    if @timelines
      case action
      when :clear, :update, :refresh
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
