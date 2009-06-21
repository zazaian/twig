
class Twig::My
  attr_reader :info, :favorites, :followers
  def initialize(client)
    @client = client
  end

  def info(action=nil)
    if @info
      case action
      when :update
        @info = @client.my(:info)
      when nil
        @info
      else
        raise ArgumentError, "#{action} is not a valid argument for @info."
      end
    else
      @info = @client.my(:info)
    end
  end

  def favorites(action=nil)
    if @favorites
      case action
      when :update
        @favorites = @client.favorites
      when nil
        @favorites
      else
        raise ArgumentError, "#{action} is not a valid argument for @favorites."
      end
    else
      @favorites = @client.favorites
    end
  end

  def followers(action=nil)
    if @followers
      case action
      when :update
        @followers = @client.my(:followers)
      when nil
        @followers
      else
        raise ArgumentError, "#{action} is not a valid argument for @followers."
      end
    else
      @followers = @client.my(:followers)
    end
  end
end

module Twig::My::Methods
  attr_reader :my
  def my(action=nil)
    if @my
      case action
      when :update
        @my = Twig::My.new(@client)
      when nil
        @my
      else
        raise ArgumentError
      end
    else
      @my = Twig::My.new(@client)
    end
  end

  def info(action=nil)
    my.info(action)
  end

  def favorites(action=nil)
    my.favorites(action)
  end
  alias_method :favs, :favorites

  def followers(action=nil)
    my.followers(action)
  end
  
  def timeline(action=nil)
    timelines.mine.all(action)
  end

end
