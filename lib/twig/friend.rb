
class Twig::Friend
  attr_accessor :client, :all, :active, :timeline, :is_friend
  def initialize(client)
    @client = client
    update
  end

  def update
    @active = number
    @is_friend = true
  end

  def is_friend
    @is_friend = @is_friend ? false : true
  end

  def all(action=nil)
    if @all
      case action
      when :update
        @all = @client.my(:friends)
      when nil
        @all
      else
        raise ArgumentError, "#{action} is not a valid argument for @all."
      end
    else
      @all = @client.my(:friends)
    end
  end

  def number(num=0)
    friends = all
    selected = friends[num]
    if selected
      output = selected
    else
      output = nil
      total = friends.size
      raise ArgumentError, "Friend #{num} does not exist.  You only have #{total} on Twitter."
    end

    return output
  end

  def timeline(action=nil)
    if @timeline
      case action
      when :update
        @timeline = @client.timeline_for(:friend, @active.id)
      when nil
        @timeline
      else
        raise ArgumentError, "#{action} is not a valid argument for friend.timeline."
      end
    else
      @timeline = @client.timeline_for(:friend, @active.id)
    end
  end

  def befriend(id=nil)
    if ! @is_friend
      output = @active.befriend
      is_friend
    else
      output = nil
      raise ArgumentError, "'#{@active.screen_name}' is already your friend."
    end

    return output
  end


  def defriend(id=nil)
    if @is_friend
      output = @active.defriend
      is_friend
    else
      output = nil
      raise ArgumentError, "'#{@active.screen_name}' is not currently your friend."
    end

    return output
  end

  def find(opts={})
    id = opts[:id] ? opts[:id] : nil
    screen_name = opts[:screen_name] ? opts[:screen_name] : nil
    activate = opts[:activate] ? opts[:activate] : true

    if id || screen_name
      if id && screen_name
        output = nil
        raise ArgumentError, "Use only screen name OR id # when finding a friend."
      else
        friends = all
        if id 
          friends.each do |f|
            if f.id == id
              output = f
              break
            end
          end
        elsif screen_name
          friends.each do |f|
            if f.screen_name == screen_name
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
            raise "Couldn't find screen_name '#{screen_name}'"
          end
        end
      end
    else
      output = nil
      raise ArgumentError, "You must use either an id# or a screen name to find a friend."
    end

    return output
  end

  def screen_name(name)
    find :screen_name => name
  end

  def id(num)
    find :id => num
  end
end

module Twig::Friend::Methods
  attr_reader :friend
  def friend(action=nil)
    if @friend
      case action
      when :create
        @friend = Twig::Friend.new(@client)
      when :update
        @friend.update
      when nil
        @friend
      else
        raise ArgumentError, "#{action} is not a valid argument for @friend."
      end
    else
      @friend = Twig::Friend.new(@client)
    end
  end

  def friends(action=nil)
    @friend.all(action)
  end
end
