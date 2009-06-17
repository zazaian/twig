
class Twig::FriendBox
  attr_accessor :client, :all, :active, :find, :sort_by
  def initialize(client)
    @client = client
    @active = first
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

  def all(action=nil)
    if @all
      case action
      when :update
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

  def sort_by(ivar, opts={})
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
            if f.info.screen_name == screen_name
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

  def activate(arg)
    case arg
    when Fixnum
      find :id => arg, :activate => true
    when String
      find :screen_name => arg, :activate => true
    else
      raise ArgumentError, "#{action} is not a valid argument for @activate."
    end
  end

  def screen_name(name)
    find :screen_name => name
  end

  def sn(name)
    screen_name(name)
  end

  def id(num)
    find :id => num
  end 
  
  def first
    all[0]
  end

  def last
    all[all.size - 1]
  end

end



class Twig::Friend
  attr_accessor :client, :info, :timeline, :is_friend
  def initialize(client, info)
    @client = client
    @info = info
  end

  def toggle
    @is_friend = @is_friend ? false : true
  end

  def is_friend?
    @is_friend
  end

  def message(text)
    if text.size <= 140
      @client.message(:post, text, @info)
    else
      raise ArgumentError, "Direct Messages (DMs) must be no longer than 140 characters."
    end
  end

  def timeline(action=nil)
    if @timeline
      case action
      when :update
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

  def befriend(id=nil)
    if ! @is_friend
      output = @info.befriend
      is_friend
    else
      output = nil
      raise ArgumentError, "'#{@info.screen_name}' is already your friend."
    end

    return output
  end


  def defriend(id=nil)
    if @is_friend
      output = @info.defriend
      is_friend
    else
      output = nil
      raise ArgumentError, "'#{@info.screen_name}' is not currently your friend."
    end

    return output
  end

end

module Twig::Friend::Methods
  attr_reader :friend, :friend_box
  def friend_box(action=nil)
    if @friend_box
      case action
      when :create
        @friend_box = Twig::FriendBox.new(@client)
      when :update
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

  def friends(action=nil)
    friend_box(action)
  end

  def friend(action=nil)
    case action 
    when Fixnum
      friend_box.id(action)
    when String
      friend_box.sn(action)
    when nil
      friend_box.active
    end
  end
end

