
class Twig::My
  attr_reader :info, :favorites, :followers
  def initialize(client)
    @client = client
  end
 
  # Returns the Twitter::User info object for the logged-in Twig::My user.
  #
  # If _info_ hasn't been called yet, or if _action_ is :update, :sync, or
  # :refresh, the Twitter::User object will be cleared and a current one
  # will be fetched from the server.
  #
  def info(action=nil)
    if @info
      case action
      when :update, :sync, :refresh
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

  # Returns an Array of all favorited Twitter::Status objects for the logged-in
  # Twig::My user.
  #
  # If _favorites_ hasn't been called yet, or if _action_ is :update, :sync, or
  # :refresh, the Array will be cleared and refreshed with the users favorite
  # Twitter::Status objects from the Twitter server.
  #
  def favorites(action=nil)
    if @favorites
      case action
      when :update, :sync, :refresh
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
  alias_method :favs, :favorites

  # Returns an Array of all followers for the logged-in Twig::My user as
  # Twitter::User objects.
  #
  # If _followers_ hasn't been called yet, or if _action_ is :update, :sync, or
  # :refresh, the Array will be cleared and refreshed with a current list of
  # Twitter::User followers from the Twitter server.
  #
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

  # Provides access to the Twig::My object.
  #
  # If _my_ hasn't been called yet, or if _action_ is :clear, :empty  or :destroy,
  # a new Twig::My object will be instantiated and all _info_, _favorites_,
  # _followers_ and _timeline_objects inside will be deleted.
  #
  def my(action=nil)
    if @my
      case action
      when :empty, :clear, :destroy
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

  # Provides direct access to the Twig::My.info method
  #
  def info(action=nil)
    my.info(action)
  end

  # Provides direct access to the Twig::My.favorites method
  #
  def favorites(action=nil)
    my.favorites(action)
  end
  alias_method :favs, :favorites

  # Provides direct access to the Twig::My.followers method
  #
  def followers(action=nil)
    my.followers(action)
  end
  
  # Provides direct access to the Twig::My.timeline method
  #
  def timeline(action=nil)
    timelines.mine.all(action)
  end

end
